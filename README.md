# dotfiles

Mac development environment for M4 Mac Mini.

## Setup from Scratch

```bash
# 1. Install Xcode CLI tools and Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Clone and bootstrap
brew install git
git clone <this-repo> ~/Github/dotfiles
bash ~/Github/dotfiles/install.sh
```

Then complete the steps in [manual-steps.md](manual-steps.md).

## Keeping Machines in Sync

```bash
# After changing anything:
cd ~/Github/dotfiles
bash extract.sh          # captures current state
git add -A && git commit -m "update" && git push

# On the other machine:
cd ~/Github/dotfiles && git pull
brew bundle --file=Brewfile   # if Brewfile changed
```

## Structure

```
dotfiles/
├── Brewfile                        # Homebrew formulae and casks
├── install.sh                      # Bootstrap a fresh Mac
├── extract.sh                      # Capture current Mac state
├── defaults.sh                     # macOS system preferences
├── manual-steps.md                 # Post-bootstrap checklist
├── shell/
│   ├── .zshrc                      # Shell config, aliases, functions
│   └── .zprofile                   # Login shell (brew shellenv)
├── git/
│   ├── .gitconfig                  # Git user + LFS
│   └── .gitignore_global           # System-wide gitignore
├── ssh/
│   └── config                      # SSH host shortcuts (no keys)
├── vscode/
│   ├── settings.json               # Editor settings
│   ├── keybindings.json            # Custom keybindings
│   └── extensions.txt              # Extension IDs
├── config/
│   ├── linearmouse/linearmouse.json # Mouse config (Razer Viper V2 Pro)
│   ├── gh/config.yml               # GitHub CLI preferences
│   └── claude.json                 # Claude Code config (sanitized)
├── launchagents/
│   └── com.lwouis.alt-tab-macos.plist
└── conda/
    └── *.yml                       # Exported conda environments
```

## What's Automated vs Manual

| Automated by install.sh | Manual (see manual-steps.md) |
|---|---|
| Homebrew packages + casks | iCloud sign-in |
| Shell config (.zshrc, .zprofile) | Internet accounts |
| Git config | CLI auth (gh, gcloud, claude) |
| SSH config | App sign-ins |
| VS Code settings + extensions | Antigravity, Texifier |
| App configs (linearmouse, gh) | Raycast cloud sync |
| macOS defaults (dock, finder, etc.) | |
| LaunchAgents | |
| Claude Code CLI + config | |
| Conda environments | |

## Not Captured (by design)

- SSH private keys (generated fresh per machine)
- Auth tokens (gh, gcloud, Claude, Raycast)
- Keychain data (syncs via iCloud)
- macOS notification preferences
- TCC/Privacy permissions (granted per-app on first use)
