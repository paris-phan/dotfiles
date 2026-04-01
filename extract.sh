#!/bin/bash
# =============================================================================
# extract.sh — Capture current Mac state into the dotfiles repo
# Usage: bash ~/Github/dotfiles/extract.sh
# =============================================================================
set -e

# Auto-detect dotfiles directory (where this script lives)
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"; }
warn() { echo -e "  ${YELLOW}! $1${NC}"; }
info() { echo -e "  $1"; }

# Ensure directories exist
mkdir -p "$DOTFILES_DIR"/{shell,git,ssh,vscode,config/linearmouse,config/gh,launchagents,conda}

# ─── 1. Brewfile ─────────────────────────────────────────────────────────────
step "Dumping Brewfile..."
brew bundle dump --file="$DOTFILES_DIR/Brewfile.generated" --describe --force
info "Wrote Brewfile.generated ($(wc -l < "$DOTFILES_DIR/Brewfile.generated" | tr -d ' ') lines)"
info "Review and merge into Brewfile when ready."

# ─── 2. Shell configs ───────────────────────────────────────────────────────
step "Copying shell configs..."
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$DOTFILES_DIR/shell/.zshrc" && info "Copied .zshrc"
[ -f "$HOME/.zprofile" ] && cp "$HOME/.zprofile" "$DOTFILES_DIR/shell/.zprofile" && info "Copied .zprofile"

# ─── 3. Git configs ─────────────────────────────────────────────────────────
step "Copying git configs..."
[ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig" && info "Copied .gitconfig"
[ -f "$HOME/.gitignore_global" ] && cp "$HOME/.gitignore_global" "$DOTFILES_DIR/git/.gitignore_global" && info "Copied .gitignore_global"

# ─── 4. SSH config (not keys!) ──────────────────────────────────────────────
step "Copying SSH config (keys excluded)..."
if [ -f "$HOME/.ssh/config" ]; then
  cp "$HOME/.ssh/config" "$DOTFILES_DIR/ssh/config"
  info "Copied ssh config"
else
  warn "No ~/.ssh/config found"
fi

# ─── 5. VS Code ─────────────────────────────────────────────────────────────
step "Extracting VS Code configuration..."
VSCODE_USER="$HOME/Library/Application Support/Code/User"

# Detect VS Code CLI
CODE_CMD=""
if command -v code &>/dev/null; then
  CODE_CMD="code"
elif [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
  CODE_CMD="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [ -n "$CODE_CMD" ]; then
  "$CODE_CMD" --list-extensions > "$DOTFILES_DIR/vscode/extensions.txt"
  info "Exported $(wc -l < "$DOTFILES_DIR/vscode/extensions.txt" | tr -d ' ') extensions"
else
  warn "VS Code CLI not found. Extensions list not updated."
fi

[ -f "$VSCODE_USER/settings.json" ] && cp "$VSCODE_USER/settings.json" "$DOTFILES_DIR/vscode/settings.json" && info "Copied settings.json"
[ -f "$VSCODE_USER/keybindings.json" ] && cp "$VSCODE_USER/keybindings.json" "$DOTFILES_DIR/vscode/keybindings.json" && info "Copied keybindings.json"

if [ -d "$VSCODE_USER/snippets" ] && [ "$(ls -A "$VSCODE_USER/snippets" 2>/dev/null)" ]; then
  cp -r "$VSCODE_USER/snippets" "$DOTFILES_DIR/vscode/snippets"
  info "Copied snippets/"
fi

# ─── 6. App configs (~/.config/) ────────────────────────────────────────────
step "Copying app configs..."

# LinearMouse
if [ -f "$HOME/.config/linearmouse/linearmouse.json" ]; then
  cp "$HOME/.config/linearmouse/linearmouse.json" "$DOTFILES_DIR/config/linearmouse/linearmouse.json"
  info "Copied linearmouse config"
fi

# GitHub CLI (preferences only, NOT hosts.yml with tokens)
if [ -f "$HOME/.config/gh/config.yml" ]; then
  cp "$HOME/.config/gh/config.yml" "$DOTFILES_DIR/config/gh/config.yml"
  info "Copied gh CLI config (auth excluded)"
fi

# Claude Code config (strip sensitive fields)
if [ -f "$HOME/.claude.json" ]; then
  python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
# Strip sensitive / ephemeral fields
for key in ['userID', 'firstStartTime', 'cachedGrowthBookFeatures',
            'cachedExtraUsageDisabledReason', 'opusProMigrationComplete',
            'sonnet1m45MigrationComplete', 'changelogLastFetched']:
    data.pop(key, None)
# Strip project-specific data (paths are machine-dependent)
data['projects'] = {}
with open(sys.argv[2], 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" "$HOME/.claude.json" "$DOTFILES_DIR/config/claude.json"
  info "Copied claude.json (sensitive fields stripped)"
fi

# ─── 7. LaunchAgents ────────────────────────────────────────────────────────
step "Copying user LaunchAgents..."
if [ -d "$HOME/Library/LaunchAgents" ]; then
  for plist in "$HOME/Library/LaunchAgents"/*.plist; do
    [ -f "$plist" ] || continue
    name="$(basename "$plist")"
    # Skip auto-generated plists from Apple and Google
    case "$name" in
      com.apple.*|com.google.*) continue ;;
    esac
    cp "$plist" "$DOTFILES_DIR/launchagents/$name"
    info "Copied $name"
  done
fi

# ─── 8. Conda environments ──────────────────────────────────────────────────
step "Exporting Conda environments..."
if command -v conda &>/dev/null; then
  for env_name in $(conda env list | grep -v '^#' | grep -v '^$' | awk '{print $1}'); do
    if [ "$env_name" != "base" ]; then
      conda env export -n "$env_name" --no-builds > "$DOTFILES_DIR/conda/${env_name}.yml" 2>/dev/null && \
        info "Exported conda env: $env_name"
    fi
  done
  env_count=$(ls "$DOTFILES_DIR/conda"/*.yml 2>/dev/null | wc -l | tr -d ' ')
  [ "$env_count" = "0" ] && info "No non-base conda environments to export."
else
  warn "Conda not found"
fi

# ─── 9. Cross-reference: apps not in Brewfile ───────────────────────────────
step "Checking for apps not managed by Homebrew..."
echo ""
for app in /Applications/*.app; do
  app_name="$(basename "$app" .app)"
  # Skip system apps
  case "$app_name" in
    Safari|Utilities|Developer|Applications\ External) continue ;;
  esac
  # Check if in Brewfile
  if ! grep -qi "$app_name" "$DOTFILES_DIR/Brewfile" 2>/dev/null; then
    echo -e "  ${YELLOW}Not in Brewfile:${NC} $app_name"
  fi
done

# ─── Summary ────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Extraction complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Files written to: $DOTFILES_DIR"
echo ""
echo "  Next steps:"
echo "  1. Review Brewfile.generated vs Brewfile for any new packages"
echo "  2. Review diffs: git diff"
echo "  3. Commit: git add -A && git commit -m 'update configs'"
echo ""
