#!/bin/bash
# =============================================================================
# install.sh — Bootstrap a fresh Mac to match the Mac Mini
# Usage: git clone <repo> ~/dotfiles && bash ~/dotfiles/install.sh
# =============================================================================
set -e

DOTFILES_DIR="$HOME/dotfiles"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"; }
warn() { echo -e "  ${YELLOW}⚠ $1${NC}"; }

# ─── Xcode CLI Tools ────────────────────────────────────────────────────────
step "Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
  echo "  Already installed."
else
  xcode-select --install
  echo "  Waiting for install... Press enter when done."
  read -r
fi

# ─── Homebrew ────────────────────────────────────────────────────────────────
step "Homebrew..."
if command -v brew &>/dev/null; then
  echo "  Already installed."
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ─── Brew Bundle ─────────────────────────────────────────────────────────────
step "Installing from Brewfile..."
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock
else
  warn "No Brewfile found. Skipping."
fi

# ─── Conda init ──────────────────────────────────────────────────────────────
step "Initializing Conda..."
if command -v conda &>/dev/null; then
  conda init "$(basename "${SHELL}")"
  echo "  Conda initialized for $(basename "${SHELL}")"
else
  warn "Conda not found. Install miniconda first."
fi

# ─── Symlinks ────────────────────────────────────────────────────────────────
step "Symlinking dotfiles..."

link_file() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "${dest}.backup.$(date +%s)"
    warn "Backed up existing $(basename "$dest")"
  fi
  ln -sf "$src" "$dest"
  echo "  $(basename "$src") → $dest"
}

link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
[ -f "$DOTFILES_DIR/.condarc" ] && link_file "$DOTFILES_DIR/.condarc" "$HOME/.condarc"
[ -f "$DOTFILES_DIR/.npmrc" ] && link_file "$DOTFILES_DIR/.npmrc" "$HOME/.npmrc"

# SSH
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
link_file "$DOTFILES_DIR/ssh_config" "$HOME/.ssh/config"

# Starship
if [ -f "$DOTFILES_DIR/starship.toml" ]; then
  mkdir -p "$HOME/.config"
  link_file "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
fi

# ─── VS Code ────────────────────────────────────────────────────────────────
step "VS Code setup..."
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_DIR"
[ -f "$DOTFILES_DIR/vscode/settings.json" ] && link_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
[ -f "$DOTFILES_DIR/vscode/keybindings.json" ] && link_file "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"

if command -v code &>/dev/null && [ -f "$DOTFILES_DIR/vscode/extensions.txt" ]; then
  step "Installing VS Code extensions..."
  grep -v '^#' "$DOTFILES_DIR/vscode/extensions.txt" | grep -v '^$' | while read -r ext; do
    code --install-extension "$ext" --force 2>/dev/null || warn "Failed: $ext"
  done
fi

# ─── Claude Code ─────────────────────────────────────────────────────────────
step "Installing Claude Code..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
  echo "  Installed Claude Code"
else
  echo "  Already installed."
fi

# ─── PATH setup ──────────────────────────────────────────────────────────────
# Already handled by .zshrc symlink, but ensure .local/bin exists
mkdir -p "$HOME/.local/bin"

# ─── SSH Key ─────────────────────────────────────────────────────────────────
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
  echo "  Or just run: gh auth login"
else
  echo "  Already exists."
fi

# ─── Conda Environments ─────────────────────────────────────────────────────
step "Restoring Conda environments..."
if [ -d "$DOTFILES_DIR/conda" ] && command -v conda &>/dev/null; then
  for yml in "$DOTFILES_DIR/conda"/*.yml; do
    env_name=$(basename "$yml" .yml)
    if ! conda env list | grep -q "^${env_name} "; then
      conda env create -f "$yml" && echo "  Created env: $env_name"
    else
      echo "  Env already exists: $env_name"
    fi
  done
else
  info "  No conda envs to restore."
fi

# ─── macOS Defaults ──────────────────────────────────────────────────────────
step "Applying macOS defaults..."
source "$DOTFILES_DIR/macos/defaults.sh"

# ─── Direct Downloads Reminder ───────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Bootstrap complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Restart your terminal, then:"
echo ""
echo "  1. Sign into iCloud and sync everything"
echo "  2. Add internet accounts:"
echo "     - parisphan1234@gmail"
echo "     - paris.hphan@gmail"
echo "     - auj4yx@virginia"
echo "     - paris@greekcore"
echo "     - paris@chancellor-street"
echo ""
echo "  3. Authenticate CLIs:"
echo "     gh auth login"
echo "     gcloud auth login"
echo "     claude auth"
echo ""
echo "  4. Manual downloads needed:"
echo "     - Raycast          https://raycast.com"
echo "     - Bartender 6      https://macbartender.com"
echo "     - BetterDisplay     https://betterdisplay.pro"
echo "     - Docker Desktop   https://docker.com/products/docker-desktop"
echo "     - BasicTeX         https://tug.org/mactex/morepackages.html"
echo "     - Antigravity      (check original source)"
echo "     - Texifier         (App Store or direct)"
echo ""
echo "  5. Mac App Store apps (installed via Brewfile if mas IDs are correct):"
echo "     - Xcode, Microsoft Office, Logic Pro, MainStage"
echo "     - Final Cut Pro, GoodNotes, Things 3, Texifier"
echo ""
echo "  6. Sign into apps: Arc, Chrome, Notion, Slack, Discord, Spotify, etc."
echo ""
