set -gx EDITOR vim
set -gx VISUAL vim

set -gx RUSTUP_DIST_SERVER https://rsproxy.cn
set -gx RUSTUP_UPDATE_ROOT https://rsproxy.cn/rustup

if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end
