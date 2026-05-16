# Manual Steps After Bootstrap

Complete these after running `install.sh`. **Open a new terminal window first** so the shell change to fish takes effect.

## 1. Initialize Conda for fish (one-time)
`install.sh` ran `conda init` against the *previous* `$SHELL` (zsh). Now that fish is the default, run once from fish:
```fish
conda init fish
```
Then restart the terminal. Verify with `which conda` — it should resolve.

## 2. Sign into iCloud
- Apple ID sign-in + sync

## 3. Internet Accounts (System Settings > Internet Accounts)
- parisphan1234@gmail.com
- paris.hphan@gmail.com
- auj4yx@virginia.edu
- paris@greekcore (GreekCore)
- paris@chancellor-street (Chancellor Street)

## 4. CLI Authentication
```fish
gh auth login
gcloud auth login
claude auth
```

## 5. Manual Downloads
- **Antigravity** — not in Homebrew
- **Texifier** — App Store
- **Toggl Track** — https://toggl.com/track/toggl-desktop/

## 6. App Sign-ins
- Google Chrome
- Notion / Notion Calendar
- Slack
- Figma
- Spotify
- Linear
- GitHub Desktop
- Toggl Track
- Raycast (cloud sync restores extensions and settings)

## 7. Verify

**Shell**
- `echo $SHELL` → `/opt/homebrew/bin/fish`
- `fisher list` → `patrickf1/fzf.fish`, `jorgebucaran/autopair.fish`, `meaningful-ooo/sponge`
- `starship --version` resolves; prompt renders with starship
- `ls`, `ll`, `la`, `cat` aliases work (eza + bat)
- `z <some-dir>` jumps via zoxide
- Ctrl-R brings up fzf history search

**Configs**
- `readlink ~/.config/fish/config.fish` points into `~/Github/dotfiles/shell/fish/`
- `readlink ~/.zshrc` points into `~/Github/dotfiles/shell/`

**Apps**
- Open VS Code and check extensions loaded
- Check Dock, Finder, and screenshot settings applied
- Verify LinearMouse config loaded for Razer Viper V2 Pro

## Troubleshooting

**Terminal still opens zsh after install**
The OS reads the login shell at process launch — closing a tab isn't enough. **Fully quit** the terminal app (`⌘Q`) and reopen. Then verify:
```bash
dscl . -read ~/ UserShell    # should show /opt/homebrew/bin/fish
```
If it still shows `/bin/zsh`, `chsh` didn't run. Do it manually:
```bash
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

**Fish shows "command not found: starship/zoxide/eza/bat" on every prompt**
Those Brewfile entries failed. Run `brew bundle --file=~/Github/dotfiles/Brewfile` and start a new terminal.

**`brew bundle` failed mid-install**
`install.sh` no longer aborts on `brew bundle` failures — it warns and continues so the rest of bootstrap runs. After fixing the underlying error, re-run:
```bash
brew bundle --file=~/Github/dotfiles/Brewfile
bash ~/Github/dotfiles/install.sh    # idempotent — safe to re-run
```

**`gcloud-cli` cask fails with `virtualenv: command not found`**
The Brewfile now installs `virtualenv` first to satisfy this. If you hit it on an older Brewfile, run `brew install virtualenv` then retry the bundle.

**Fisher plugins missing**
Re-run from fish: `fisher update` (reads `~/.config/fish/fish_plugins`).
