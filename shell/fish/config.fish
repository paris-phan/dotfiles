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
