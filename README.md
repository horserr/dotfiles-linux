# Horserr's dotfiles config

[Chezmoi Home Page](https://www.chezmoi.io/)

This repo is adapted from: [twpayne's dotfiles](https://github.com/twpayne/dotfiles)

> [!CAUTION]
>
> only tested on Windows and Ubuntu24.01 LST

## Initiation

`git` should be installed

1. create local share folder if needed

   ```sh
   mkdir -p ~/.local/share
   cd ~/.local/share
   ```

2. clone the repo

   ```sh
   git clone --depth 1 https://github.com/horserr/dotfiles.git chezmoi
   cd ./chezmoi/start
   ```

3. use scripts to install apps
   - on linux:

     ```bash
     ./main.sh
     ```

   - on windows:

     ```pwsh
     ./main.ps1
     ```

4. reopen terminal
5. use `chezmoi` to place dot files

   ```sh
   chezmoi apply
   ```

6. (recommended) to use `neovim`, install `treesitter` beforehand

   ```sh
   cargo install tree-sitter-cli
   ```

7. (recommended) install `nodejs` with `nvm`

   ```sh
   nvm install --lts
   ```
