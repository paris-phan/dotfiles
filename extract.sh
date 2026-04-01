#!/bin/bash
# =============================================================================
# extract.sh — Capture your current Mac setup into the dotfiles repo
# Run this on your configured Mac Mini to populate ~/dotfiles with real data.
# Usage: bash ~/dotfiles/scripts/extract.sh
# =============================================================================
set -e

DOTFILES_DIR="$HOME/dotfiles"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"; }
warn() { echo -e "  ${YELLOW}⚠ $1${NC}"; }
info() { echo -e "  $1"; }

mkdir -p "$DOTFILES_DIR"/{vscode,macos,scripts}

# ─── 1. Brewfile ─────────────────────────────────────────────────────────────
step "Dumping Brewfile (everything installed via Homebrew)..."
brew bundle dump --file="$DOTFILES_DIR/Brewfile.generated" --describe --force
info "Wrote Brewfile.generated ($(wc -l < "$DOTFILES_DIR/Brewfile.generated" | tr -d ' ') lines)"
info "Review and rename to Brewfile when ready."

# ─── 2. Shell configs ───────────────────────────────────────────────────────
step "Copying shell configs..."
for f in .zshrc .zprofile .bashrc .bash_profile; do
  if [ -f "$HOME/$f" ]; then
    cp "$HOME/$f" "$DOTFILES_DIR/$f"
    info "Copied $f"
  fi
done

# ─── 3. Git configs ─────────────────────────────────────────────────────────
step "Copying git configs..."
[ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$DOTFILES_DIR/.gitconfig" && info "Copied .gitconfig"
[ -f "$HOME/.gitignore_global" ] && cp "$HOME/.gitignore_global" "$DOTFILES_DIR/.gitignore_global" && info "Copied .gitignore_global"

# ─── 4. SSH config (not keys!) ──────────────────────────────────────────────
step "Copying SSH config (keys excluded)..."
if [ -f "$HOME/.ssh/config" ]; then
  cp "$HOME/.ssh/config" "$DOTFILES_DIR/ssh_config"
  info "Copied ssh config"
else
  warn "No ~/.ssh/config found"
fi

# ─── 5. VS Code ─────────────────────────────────────────────────────────────
step "Extracting VS Code configuration..."
VSCODE_USER="$HOME/Library/Application Support/Code/User"
mkdir -p "$DOTFILES_DIR/vscode"

if command -v code &>/dev/null; then
  code --list-extensions > "$DOTFILES_DIR/vscode/extensions.txt"
  info "Exported $(wc -l < "$DOTFILES_DIR/vscode/extensions.txt" | tr -d ' ') extensions"
else
  warn "VS Code CLI (code) not found. Install Shell Command from VS Code command palette."
fi

if [ -f "$VSCODE_USER/settings.json" ]; then
  cp "$VSCODE_USER/settings.json" "$DOTFILES_DIR/vscode/settings.json"
  info "Copied settings.json"
fi
if [ -f "$VSCODE_USER/keybindings.json" ]; then
  cp "$VSCODE_USER/keybindings.json" "$DOTFILES_DIR/vscode/keybindings.json"
  info "Copied keybindings.json"
fi
if [ -f "$VSCODE_USER/snippets" ]; then
  cp -r "$VSCODE_USER/snippets" "$DOTFILES_DIR/vscode/snippets"
  info "Copied snippets/"
fi

# ─── 6. Starship / other tool configs ───────────────────────────────────────
step "Copying tool configs..."
[ -f "$HOME/.config/starship.toml" ] && cp "$HOME/.config/starship.toml" "$DOTFILES_DIR/starship.toml" && info "Copied starship.toml"
[ -f "$HOME/.condarc" ] && cp "$HOME/.condarc" "$DOTFILES_DIR/.condarc" && info "Copied .condarc"
[ -f "$HOME/.npmrc" ] && cp "$HOME/.npmrc" "$DOTFILES_DIR/.npmrc" && info "Copied .npmrc"

# ─── 7. Conda environments list ─────────────────────────────────────────────
step "Listing Conda environments..."
if command -v conda &>/dev/null; then
  conda env list > "$DOTFILES_DIR/conda-envs.txt"
  info "Wrote conda-envs.txt"
  # Export each env
  mkdir -p "$DOTFILES_DIR/conda"
  for env_name in $(conda env list | grep -v '^#' | grep -v '^$' | awk '{print $1}'); do
    if [ "$env_name" != "base" ]; then
      conda env export -n "$env_name" --no-builds > "$DOTFILES_DIR/conda/${env_name}.yml" 2>/dev/null && \
        info "Exported conda env: $env_name"
    fi
  done
else
  warn "Conda not found"
fi

# ─── 8. Node global packages ────────────────────────────────────────────────
step "Listing global npm packages..."
if command -v npm &>/dev/null; then
  npm list -g --depth=0 2>/dev/null > "$DOTFILES_DIR/npm-globals.txt"
  info "Wrote npm-globals.txt"
fi

# ─── 9. Mac App Store apps ──────────────────────────────────────────────────
step "Listing Mac App Store apps..."
if command -v mas &>/dev/null; then
  mas list > "$DOTFILES_DIR/mas-apps.txt"
  info "Wrote mas-apps.txt ($(wc -l < "$DOTFILES_DIR/mas-apps.txt" | tr -d ' ') apps)"
else
  warn "mas not installed. Run: brew install mas"
  warn "Then re-run this script to capture App Store apps."
fi

# ─── 10. Snapshot of what's in /Applications ─────────────────────────────────
step "Listing all installed applications..."
ls /Applications > "$DOTFILES_DIR/applications.txt"
ls "$HOME/Applications" >> "$DOTFILES_DIR/applications.txt" 2>/dev/null
info "Wrote applications.txt — compare against Brewfile to catch manual installs"

# ─── 11. LaunchAgents / LaunchDaemons (user) ────────────────────────────────
step "Checking for user LaunchAgents..."
if [ -d "$HOME/Library/LaunchAgents" ] && [ "$(ls -A "$HOME/Library/LaunchAgents" 2>/dev/null)" ]; then
  ls "$HOME/Library/LaunchAgents" > "$DOTFILES_DIR/launchagents.txt"
  info "Wrote launchagents.txt"
else
  info "No user LaunchAgents found"
fi

# ─── 12. Current PATH ───────────────────────────────────────────────────────
step "Saving current PATH for reference..."
echo "$PATH" | tr ':' '\n' > "$DOTFILES_DIR/path-snapshot.txt"
info "Wrote path-snapshot.txt ($(wc -l < "$DOTFILES_DIR/path-snapshot.txt" | tr -d ' ') entries)"

# ─── Summary ────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Extraction complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Files written to: $DOTFILES_DIR"
echo ""
echo "  Next steps:"
echo "  1. Review Brewfile.generated → rename to Brewfile when satisfied"
echo "  2. Check applications.txt for apps not covered by Brewfile"
echo "  3. Review .zshrc — the extracted one is your REAL config"
echo "  4. Update ssh_config placeholders (IPs, usernames)"
echo "  5. git init && git add -A && git commit -m 'initial extract'"
echo "  6. Push to GitHub"
echo ""
echo "  Files to NEVER commit:"
echo "    ~/.ssh/id_*  (private keys)"
echo "    Any .env files with secrets"
echo ""
