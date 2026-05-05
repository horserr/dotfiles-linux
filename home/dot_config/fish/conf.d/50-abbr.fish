if status is-interactive
    abbr -a p printf
    # link: https://linuxize.com/post/how-to-find-files-in-linux-using-the-command-line/
    abbr -a f "find . -maxdepth 1"
    abbr -a find-broken "find . -xtype l"
    # symbolic link dir
    abbr -a lnd "ln -sfd"

    if command -q tldr
        abbr -a m tldr
    end
    if command -q uv
        abbr -a uvv 'uv venv --system-site-packages --no-managed-python'
    end
    if command -q chezmoi
        abbr -a c chezmoi
    end

    # abbr -a ;a '&'
    # abbr -a ;s '-'
    # abbr -a ;/ '\\'
    # abbr -a ;l '|'
end

# 软连接替换原子操作，避免服务中断
# link: https://linuxize.com/post/how-to-create-symbolic-links-in-linux-using-the-ln-command/#overwriting-and-updating-symlinks
# 第一步：先创建一个临时的快捷方式
# ln -s /opt/app/releases/2.1.0 /opt/app/current.tmp

# 第二步：瞬间替换成正式的快捷方式
# mv -Tf /opt/app/current.tmp /opt/app/current

