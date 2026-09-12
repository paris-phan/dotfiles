fish_add_path -g $HOME/.local/bin

test -f $HOME/.orbstack/shell/init2.fish
and source $HOME/.orbstack/shell/init2.fish

if status is-interactive
    type -q starship; and starship init fish | source

    set -g fish_greeting "hi paris :)"

    # Modern ls
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --long --header --git'
    alias la='eza --icons --long --header --git --all'
end
