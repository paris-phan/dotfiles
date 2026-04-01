# =============================================================================
# Brewfile — Paris's Mac Setup (M4 Mac Mini, March 2026)
# Usage: brew bundle --file=~/dotfiles/Brewfile
# =============================================================================

# --- Taps -------------------------------------------------------------------
tap "homebrew/bundle"
tap "homebrew/cask-fonts"

# --- CLI Tools (brew install) -----------------------------------------------
brew "tree"
brew "node"
brew "gh"                        # GitHub CLI
brew "postgresql"
brew "cocoapods"                 # iOS dependency manager
brew "miniconda"                 # Python env manager
brew "gemini-cli"                # Google Gemini CLI

# --- Cask Apps (brew install --cask) ----------------------------------------
brew "gcloud-cli"                # Google Cloud SDK (installs as formula now)

# Utilities
cask "linearmouse"               # mouse customization
cask "appcleaner"                # clean uninstalls
cask "alt-tab"                   # Windows-style alt-tab
cask "grandperspective"          # disk usage visualizer

# =============================================================================
# Direct Downloads (not in Homebrew or preferring manual install)
# These are documented here but installed via install.sh or manually.
# =============================================================================
# cask "raycast"                 # uncomment if you want brew to manage it
# cask "bartender"               # Bartender 5+ requires direct download
# cask "betterdisplay"           # direct download preferred
# cask "basictex"                # LaTeX — or uncomment: cask "basictex"
# cask "docker"                  # Docker Desktop — direct download

# --- Dev Tools ---------------------------------------------------------------
cask "visual-studio-code"
# cask "github-desktop"          # uncomment if you want brew to manage

# --- Browsers ---------------------------------------------------------------
cask "google-chrome"
cask "arc"

# --- Productivity ------------------------------------------------------------
cask "notion"
cask "notion-calendar"
cask "linear-linear"             # Linear app
cask "figma"

# --- Communication -----------------------------------------------------------
cask "zoom"
cask "slack"                     # add if you use it
cask "discord"                   # add if you use it

# --- Media -------------------------------------------------------------------
cask "spotify"

# --- AI ----------------------------------------------------------------------
cask "claude"                    # Claude desktop app

# --- Fonts -------------------------------------------------------------------
cask "font-jetbrains-mono-nerd-font"
cask "font-fira-code-nerd-font"

# =============================================================================
# Mac App Store (requires `mas` CLI + signed into App Store)
# Get IDs with: mas search "App Name"
# =============================================================================
brew "mas"

mas "Xcode", id: 497799835
mas "Microsoft Word", id: 462054704
mas "Microsoft Excel", id: 462058435
mas "Microsoft PowerPoint", id: 462062816
mas "Microsoft Outlook", id: 985367838
mas "Microsoft OneNote", id: 784801555
mas "MainStage", id: 634159523
mas "Logic Pro", id: 634148309
mas "Final Cut Pro", id: 424389933
mas "GoodNotes 5", id: 1444383602
mas "Things 3", id: 904280696
mas "Texifier", id: 458866234
