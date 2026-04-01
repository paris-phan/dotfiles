# dotfiles

Mac development environment — M4 Mac Mini ↔ M1 Pro MacBook Pro.

## Setup from Scratch

### On a configured Mac (extract current state):
```bash
git clone <this-repo> ~/dotfiles   # or mkdir ~/dotfiles && git init
bash ~/dotfiles/scripts/extract.sh  # captures brew, vscode, shell, conda, etc.
# Review Brewfile.generated → rename to Brewfile
git add -A && git commit -m "initial" && git push
```

### On a fresh Mac (bootstrap):
```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install git
git clone <this-repo> ~/dotfiles
bash ~/dotfiles/install.sh
```

## Keeping Machines in Sync

```bash
# After changing anything on either machine:
cd ~/dotfiles && git add -A && git commit -m "update" && git push

# On the other machine:
cd ~/dotfiles && git pull
brew bundle --file=~/dotfiles/Brewfile   # if Brewfile changed
```

## Structure

```
dotfiles/
├── Brewfile                # brew formulae, casks, Mac App Store apps
├── install.sh              # bootstrap script for fresh Mac
├── .zshrc                  # shell config, aliases, PATH
├── .zprofile               # login shell env
├── .gitconfig              # git settings + aliases
├── .gitignore_global       # system-wide gitignore
├── .condarc                # conda settings (if extracted)
├── ssh_config              # SSH host shortcuts (no keys!)
├── vscode/
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt      # one extension ID per line
├── macos/
│   └── defaults.sh         # macOS system preferences
├── conda/
│   └── *.yml               # exported conda environments
├── scripts/
│   └── extract.sh          # capture current Mac state
└── README.md
```

## Manual Steps After Bootstrap

1. iCloud sign-in + sync
2. Internet accounts (Gmail ×2, UVA, GreekCore, Chancellor Street)
3. CLI auth: `gh auth login`, `gcloud auth login`, `claude auth`
4. Direct downloads: Raycast, Bartender 6, BetterDisplay, Docker Desktop, BasicTeX
5. App Store: Xcode, Office, Logic Pro, MainStage, Final Cut Pro, GoodNotes, Things 3
6. Sign into all apps
