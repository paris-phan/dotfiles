# =============================================================================
# .zshrc — Paris's Zsh Configuration
# =============================================================================

# --- Homebrew ----------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- PATH --------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"                          # Claude Code, pipx, etc.
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"  # gcloud CLI

# --- Editor ------------------------------------------------------------------
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# --- Conda (Miniconda) ------------------------------------------------------
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Don't auto-activate base env (keeps prompt clean, activate manually)
# conda config --set auto_activate_base false

# --- Google Cloud SDK --------------------------------------------------------
if [ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]; then
  source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
  source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
fi

# --- Aliases -----------------------------------------------------------------
# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -la"
alias lt="tree -L 2"

# Git
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate -20"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"

# Python / Conda
alias ca="conda activate"
alias cda="conda deactivate"
alias cel="conda env list"

# Docker
alias dps="docker ps"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"

# Misc
alias c="clear"
alias reload="source ~/.zshrc"
alias ports="lsof -i -P -n | grep LISTEN"

# --- Functions ---------------------------------------------------------------
# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Kill process on a given port
killport() { lsof -ti:"$1" | xargs kill -9 2>/dev/null && echo "Killed port $1" || echo "Nothing on port $1"; }

# --- History -----------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# --- Completion --------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# --- Key Bindings ------------------------------------------------------------
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
