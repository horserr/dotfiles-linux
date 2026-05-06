set -gx EDITOR vim
set -gx VISUAL vim

set -gx RUSTUP_DIST_SERVER https://rsproxy.cn
set -gx RUSTUP_UPDATE_ROOT https://rsproxy.cn/rustup

# use windows browser tamer to browser webpage inside wsl
if status is-interactive; and string match -qi "*microsoft*" </proc/sys/kernel/osrelease
    set -gx BROWSER bt.exe
end

# homebrew
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# vscode shell integration
string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

# forgit
if test -d "$FORGIT_INSTALL_DIR/bin"
    fish_add_path "$FORGIT_INSTALL_DIR/bin"
end
