if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

set -g fish_greeting "hi paris :)"

# Modern ls
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --long --header --git'
alias la='eza --icons --long --header --git --all'
