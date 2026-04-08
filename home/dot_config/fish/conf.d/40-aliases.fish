if status is-interactive
    # $__fish_config_dir/config.fish
    alias conf 'vim ~/.config/fish/config.fish'
    alias reload 'source ~/.config/fish/config.fish'
    alias ls 'eza --icons --group-directories-first'
    alias ll 'eza -lbgH --icons --git --group-directories-first'
    alias lt 'eza --tree --icons'
    alias cat bat
    alias cd z
    alias y yazi
    alias top btop

    if command -q fdfind
        alias fd fdfind
    end
end
