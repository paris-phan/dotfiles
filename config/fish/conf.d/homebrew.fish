# Put Homebrew on PATH even when /etc/paths.d/homebrew is absent.
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end
