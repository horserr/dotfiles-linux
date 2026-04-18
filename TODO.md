- vscode server run on change to install extentions from extension list
- use chezmoi to manage external plugin manager, like fisher and tmux plugin

wsl中需要安装socat来配合windows上的npiperelay

ssh config和windows的同步

ssh 文件夹中的权限需要设置
```sh
chmod 700 ~/.ssh
chmod 644 ~/.ssh/*.pub
```

git gpg.ssh.allowedSignersFile

git config --global gpg.ssh.allowedSignersFile "~/.config/git/allowed_signers"

安装 azure cli
```sh
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

安装 nix
```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

安装 pixi
```sh
curl -fsSL https://pixi.sh/install.sh | bash
```
