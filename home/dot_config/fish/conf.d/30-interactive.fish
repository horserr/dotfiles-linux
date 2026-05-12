if status is-interactive
    fish_vi_key_bindings

    bind -M default \ee edit_command_buffer
    set -g fish_vi_force_cursor 1
    set -gx FZF_DEFAULT_OPTS '--preview "batcat --color=always --style=numbers --line-range :500 {}"'
end
