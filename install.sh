#!/bin/bash
# =============================================================================
# install.sh — Bootstrap a fresh Mac
# Usage: git clone <repo> ~/Github/dotfiles && bash ~/Github/dotfiles/install.sh
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

link_file() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "${dest}.backup.$(date +%s)"
    warn "Backed up existing $(basename "$dest")"
  fi
  ln -sf "$src" "$dest"
  echo "  $(basename "$src") -> $dest"
}

# ─── 1. Xcode CLI Tools ────────────────────────────────────────────────────
step "Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
  echo "  Already installed."
else
  xcode-select --install
  echo "  Waiting for install... Press enter when done."
  read -r
fi

# ─── 2. Homebrew ────────────────────────────────────────────────────────────
step "Homebrew..."
if command -v brew &>/dev/null; then
  echo "  Already installed."
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ─── 3. Brew Bundle ─────────────────────────────────────────────────────────
step "Installing from Brewfile..."
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  brew bundle --file="$DOTFILES_DIR/Brewfile"
else
  warn "No Brewfile found. Skipping."
fi

# ─── 4. Conda init ──────────────────────────────────────────────────────────
step "Initializing Conda..."
CONDA_SH="/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
if [ -f "$CONDA_SH" ]; then
  source "$CONDA_SH"
  conda init "$(basename "${SHELL}")"
  echo "  Conda initialized."
else
  warn "Conda not found. Miniconda may not have installed yet."
fi

# ─── 5. Shell config symlinks ──────────────────────────────────────────────
step "Symlinking shell configs..."
link_file "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/shell/.zprofile" "$HOME/.zprofile"

# ─── 6. Git config symlinks ────────────────────────────────────────────────
step "Symlinking git configs..."
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# ─── 7. SSH config ─────────────────────────────────────────────────────────
step "SSH config..."
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if [ -f "$DOTFILES_DIR/ssh/config" ]; then
  link_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
fi

# ─── 8. VS Code ────────────────────────────────────────────────────────────
step "VS Code setup..."
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_DIR"

[ -f "$DOTFILES_DIR/vscode/settings.json" ] && link_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
[ -f "$DOTFILES_DIR/vscode/keybindings.json" ] && link_file "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"

if [ -d "$DOTFILES_DIR/vscode/snippets" ]; then
  ln -sf "$DOTFILES_DIR/vscode/snippets" "$VSCODE_DIR/snippets"
  echo "  snippets/ -> $VSCODE_DIR/snippets"
fi

# Install extensions
CODE_CMD=""
if command -v code &>/dev/null; then
  CODE_CMD="code"
elif [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
  CODE_CMD="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [ -n "$CODE_CMD" ] && [ -f "$DOTFILES_DIR/vscode/extensions.txt" ]; then
  step "Installing VS Code extensions..."
  grep -v '^#' "$DOTFILES_DIR/vscode/extensions.txt" | grep -v '^$' | while read -r ext; do
    "$CODE_CMD" --install-extension "$ext" --force 2>/dev/null || warn "Failed: $ext"
  done
fi

# ─── 9. App configs ────────────────────────────────────────────────────────
step "Restoring app configs..."

# LinearMouse
if [ -f "$DOTFILES_DIR/config/linearmouse/linearmouse.json" ]; then
  mkdir -p "$HOME/.config/linearmouse"
  link_file "$DOTFILES_DIR/config/linearmouse/linearmouse.json" "$HOME/.config/linearmouse/linearmouse.json"
fi

# GitHub CLI
if [ -f "$DOTFILES_DIR/config/gh/config.yml" ]; then
  mkdir -p "$HOME/.config/gh"
  link_file "$DOTFILES_DIR/config/gh/config.yml" "$HOME/.config/gh/config.yml"
fi

# Claude Code config (copy, not symlink — Claude modifies this at runtime)
if [ -f "$DOTFILES_DIR/config/claude.json" ]; then
  cp "$DOTFILES_DIR/config/claude.json" "$HOME/.claude.json"
  echo "  claude.json -> ~/.claude.json (copied)"
fi

# ─── 10. LaunchAgents ──────────────────────────────────────────────────────
step "Restoring LaunchAgents..."
mkdir -p "$HOME/Library/LaunchAgents"
for plist in "$DOTFILES_DIR/launchagents"/*.plist; do
  [ -f "$plist" ] || continue
  name="$(basename "$plist")"
  cp "$plist" "$HOME/Library/LaunchAgents/$name"
  launchctl load "$HOME/Library/LaunchAgents/$name" 2>/dev/null || true
  echo "  Loaded $name"
done

# ─── 11. macOS Defaults ────────────────────────────────────────────────────
step "Applying macOS defaults..."
source "$DOTFILES_DIR/defaults.sh"

# ─── 12. Claude Code CLI ───────────────────────────────────────────────────
step "Claude Code..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
  echo "  Installed Claude Code CLI."
else
  echo "  Already installed."
fi

# ─── 13. SSH Key ───────────────────────────────────────────────────────────
step "SSH key..."
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo -n "  Email for SSH key: "
  read -r email
  ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
  eval "$(ssh-agent -s)"
  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
  echo ""
  echo "  Public key (add to GitHub):"
  cat "$HOME/.ssh/id_ed25519.pub"
  echo ""
else
  echo "  Already exists."
fi

# ─── 14. Conda Environments ────────────────────────────────────────────────
step "Restoring Conda environments..."
if [ -d "$DOTFILES_DIR/conda" ] && command -v conda &>/dev/null; then
  for yml in "$DOTFILES_DIR/conda"/*.yml; do
    [ -f "$yml" ] || continue
    env_name=$(basename "$yml" .yml)
    if ! conda env list | grep -q "^${env_name} "; then
      conda env create -f "$yml" && echo "  Created env: $env_name"
    else
      echo "  Env already exists: $env_name"
    fi
  done
else
  echo "  No conda envs to restore."
fi

# ─── 15. Ensure directories exist ──────────────────────────────────────────
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Screenshots"

# ─── Done ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Bootstrap complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Restart your terminal, then complete the manual steps:"
echo "  See: $DOTFILES_DIR/manual-steps.md"
echo ""
