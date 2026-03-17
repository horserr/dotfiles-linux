#!/bin/bash
set -euo pipefail  # 开启严格模式
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

essentials=(
  "build-essential"
  "curl"
  "procps"
  "file"
  "git"
  "gcc"
  "make"
  "fish"
  "openssh"
)

userapps=(
  "neovim"
  "chezmoi"
  "gh"
  "fzf"
  "bat"
  "eza"
  "zoxide"
  "fd"
  "ripgrep"
  "tldr"
  "btop"
  "lazygit"
  "yazi"
  "ffmpeg"
  "7zip"
  "jq"
  "poppler"
  "imagemagick"
)

# 检查是否为 root 用户（apt 安装需要 root 权限）
# if [ "$(id -u)" -ne 0 ]; then
#   echo "❌错误：该脚本需要以 root 权限运行！"
#   echo "⚠️请使用 sudo 执行，例如：sudo $0"
#   exit 1
# fi

install-apps() {
  # 获取第一个参数作为管理器 (例如 apt 或 brew)
  local manager=$1
  # 移除第一个参数，剩下的 $@ 就是软件列表
  shift

  for app in "$@"; do
    if command -v "$app" >/dev/null 2>&1; then
      echo "✅ $app 已安装，跳过"
    else
      echo "📦 正在使用 $manager 安装 $app ..."

      # 根据管理器选择安装命令
      case $manager in
        apt)  sudo apt install -y "$app" >/dev/null 2>&1 ;;
        brew) brew install "$app" >/dev/null 2>&1 ;;
        *)    echo "❌ 不支持的管理器: $manager"; return 1 ;;
      esac

      if [ $? -ne 0 ]; then
        echo "❌ $app 安装失败！"
      else
        echo "✅ $app 安装成功"
      fi
    fi
  done
}

# 定义颜色
GREEN='\033[0;32m'
NC='\033[0m'

# change apt source
echo -e "${GREEN}正在配置 APT 镜像源...${NC}"
TARGET_FILE="/etc/apt/sources.list.d/ubuntu.sources"
NEW_MIRROR="https://mirrors.nju.edu.cn/ubuntu/"
sudo cp "$TARGET_FILE" "${TARGET_FILE}.bak"
sudo sed -i "s|^URIs:.*|URIs: ${NEW_MIRROR}|g" "$TARGET_FILE"

# update & upgrade apt
sudo apt update && sudo apt upgrade -y

# install essential apps
echo -e "${GREEN}准备安装essential apps...${NC}"

install-apps apt "${essentials[@]}"

# homebrew
echo -e "${GREEN}正在准备安装 Homebrew...${NC}"
# 设置环境变量指向清华镜像
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 更新 brew
brew update

# install rustup
echo -e "${GREEN}准备安装rustup...${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install nvm
echo -e "${GREEN}准备安装nvm...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# install uv
echo -e "${GREEN}准备安装uv...${NC}"
curl -lsSf https://astral.sh/uv/install.sh | sh

# install user apps
echo -e "${GREEN}准备安装常用软件...${NC}"
install-apps brew "${userapps[@]}"

# use chezmoi to update config
echo -e "${GREEN}deploying chezmoi...${NC}"
chezmoi init

echo -e "${GREEN}切换shell为fish...${NC}"
chsh -s $(which fish)

echo -e "${GREEN}请退出后重新进入...${NC}"