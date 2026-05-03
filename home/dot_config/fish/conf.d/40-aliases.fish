if status is-interactive
    # $__fish_config_dir/config.fish
    alias conf '$EDITOR ~/.config/fish/config.fish'
    alias reload 'source ~/.config/fish/config.fish'

    if command -q eza
        alias ls 'eza --icons --group-directories-first'
        alias ll 'eza -lbgH --icons --git --group-directories-first'
        alias lt 'eza --tree --icons'
    end

    # fd
    if command -q fdfind
        alias fd fdfind
    end

    # btop
    if command -q btop
        alias top btop
    end

    # bat
    if command -q bat
        alias cat bat
    end

    # yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end

# find . -globstar -path "**/config/**/*.yaml"
# name, type, iname, path
