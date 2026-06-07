if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

# Hide the default greeting
set -g fish_greeting ""

# Zoxide (smarter cd)
zoxide init fish | source

# Modern ls
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --long --header --git'
alias la='eza --icons --long --header --git --all'

# Better cat
alias cat='bat --style=auto'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/homebrew/Caskroom/miniconda/base/bin/conda
    eval /opt/homebrew/Caskroom/miniconda/base/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/homebrew/Caskroom/miniconda/base/etc/fish/conf.d/conda.fish"
        . "/opt/homebrew/Caskroom/miniconda/base/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/homebrew/Caskroom/miniconda/base/bin" $PATH
    end
end
# <<< conda initialize <<<


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/parisphan/Downloads/google-cloud-sdk/path.fish.inc' ]; . '/Users/parisphan/Downloads/google-cloud-sdk/path.fish.inc'; end


# Added by Antigravity CLI installer
set -gx PATH "/Users/parisphan/.local/bin" $PATH

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
