if status is-interactive
    # 用 eza 代替 ls
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -lgh --icons --group-directories-first"

    # 用 bat 代替 cat (不带分页)
    alias cat="bat -pp"

    # 用 zoxide 代替 cd
    zoxide init fish | source
    alias cd="z"

    # 快速打开 yazi
    alias y="yazi"
end

# Homebrew 清华源配置
set -gx HOMEBREW_API_DOMAIN "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

# 备选：core 源（按需添加）
set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"