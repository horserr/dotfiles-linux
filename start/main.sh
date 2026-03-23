#!/bin/bash
set -euo pipefail  # 开启严格模式

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_DIR/linuxapps.sh"

ensure_installed() {
  local cmd=$1
  local install_script=$2

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ $cmd 已安装"
  else
    echo "📦 正在安装 $cmd..."
    eval "$install_script"
  fi
}

install_apps() {
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
        apt)  sudo apt install -y "$app" >/dev/null 2>&1 && echo "✅ $app 安装成功" || echo "❌ $app 安装失败！" ;;
        brew) brew install "$app" >/dev/null 2>&1 && echo "✅ $app 安装成功" || echo "❌ $app 安装失败！" ;;
        *)    echo "❌ 不支持的管理器: $manager"; return 1 ;;
      esac
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

install_apps apt "${essentials[@]}"

# homebrew
echo -e "${GREEN}正在准备安装 Homebrew...${NC}"
# 设置环境变量指向清华镜像
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

ensure_installed "brew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 更新 brew
brew update

# install rustup
echo -e "${GREEN}准备安装rustup...${NC}"
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

ensure_installed 'rustup' "curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh"

# install nvm
echo -e "${GREEN}准备安装nvm...${NC}"
ensure_installed 'nvm' "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# install uv
echo -e "${GREEN}准备安装uv...${NC}"
ensure_installed "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"

# install user apps
echo -e "${GREEN}准备安装常用软件...${NC}"
install_apps brew "${userapps[@]}"

# use chezmoi to update config
echo -e "${GREEN}deploying chezmoi...${NC}"
chezmoi init
chezmoi apply

# install fisher
echo -e "${GREEN}install fisher...${NC}"
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# 安装nvm插件
fisher install jorgebucaran/nvm.fish

echo -e "${GREEN}切换shell为fish...${NC}"
chsh -s $(which fish)

echo -e "${GREEN}请退出后重新进入...${NC}"