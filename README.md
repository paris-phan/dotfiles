# dotfiles

Mac development environment for M4 Mac Mini.

Default shell is **fish** (with [fisher](https://github.com/jorgebucaran/fisher) plugins), prompt is [starship](https://starship.rs/). Zsh config is also captured for fallback.

## Setup from Scratch

```bash
# 1. Xcode CLI tools and Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Clone and bootstrap
brew install git
git clone <this-repo> ~/Github/dotfiles
bash ~/Github/dotfiles/install.sh
```

`install.sh` will, in order:

1. Install Xcode CLI Tools (skip if present)
2. Install Homebrew (skip if present)
3. `brew bundle` — installs everything in `Brewfile` (fish, starship, zoxide, eza, bat, cocoapods, gh, node, postgresql@18, tree, plus all cask apps)
4. Initialize Conda for the current `$SHELL`
5. Symlink zsh configs (`.zshrc`, `.zprofile`) into `~`
6. **Set up fish:** symlink `config.fish`, `fish_plugins`, and any themes; add `/opt/homebrew/bin/fish` to `/etc/shells` (sudo prompt); `chsh -s` to fish; bootstrap fisher and run `fisher update` to install plugins from `fish_plugins`
7. Symlink git configs
8. Create `~/.ssh`, symlink ssh config
9. Symlink VS Code settings + keybindings + snippets, install extensions from `extensions.txt`
10. Symlink LinearMouse, gh CLI, and Claude Code configs
11. Copy LaunchAgents into `~/Library/LaunchAgents` and `launchctl load` them
12. Apply macOS system defaults (`defaults.sh`)
13. Install Claude Code CLI
14. Generate ed25519 SSH key (interactive — prompts for email)
15. Restore Conda environments from `conda/*.yml`

When it finishes, **open a new terminal** so the shell change takes effect, then complete the steps in [manual-steps.md](manual-steps.md).

## Keeping Machines in Sync

```bash
# After changing anything on this machine:
cd ~/Github/dotfiles
bash extract.sh          # captures current state into the repo
git add -A && git commit -m "update" && git push

# On the other machine:
cd ~/Github/dotfiles && git pull
brew bundle --file=Brewfile   # if Brewfile changed
fisher update                  # if fish_plugins changed (run from fish)
```

`extract.sh` captures: Brewfile (as `Brewfile.generated` for review), zsh configs, **fish `config.fish` + `fish_plugins` + `themes/`** (plugin-managed files in `functions/`/`completions/`/`conf.d/` are intentionally skipped — fisher rebuilds them), git configs, ssh config, VS Code settings + extensions list, LinearMouse + gh + Claude Code configs, user LaunchAgents, and Conda environments.

## Structure

```
dotfiles/
├── Brewfile                        # Homebrew formulae and casks
├── install.sh                      # Bootstrap a fresh Mac
├── extract.sh                      # Capture current Mac state
├── defaults.sh                     # macOS system preferences
├── manual-steps.md                 # Post-bootstrap checklist
├── shell/
│   ├── .zshrc                      # Zsh config (kept for fallback)
│   ├── .zprofile                   # Zsh login (brew shellenv)
│   ├── starship.toml               # Starship prompt config (→ ~/.config/)
│   ├── ghostty/config              # Ghostty terminal config (→ ~/.config/ghostty/)
│   └── fish/
│       ├── config.fish             # Fish rc — starship, zoxide, aliases
│       ├── fish_plugins            # Fisher plugin list
│       └── themes/                 # Custom fish themes (if any)
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
| Zsh config (.zshrc, .zprofile) | Internet accounts |
| Fish config + fisher plugins + default-shell switch | CLI auth (gh, gcloud, claude) |
| Starship prompt + Ghostty terminal config | App sign-ins |
| Git config | Antigravity, Texifier |
| SSH config | Raycast cloud sync |
| VS Code settings + extensions | `conda init fish` (one-time) |
| App configs (linearmouse, gh) | |
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
- Fish `fish_history` and `fish_variables` (machine-local state)
- Fish `functions/`, `completions/`, `conf.d/` content (rebuilt by `fisher update` from `fish_plugins`)
