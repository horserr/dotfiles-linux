if status is-interactive
    abbr -a p printf
    # link: https://linuxize.com/post/how-to-find-files-in-linux-using-the-command-line/
    abbr -a f find

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
