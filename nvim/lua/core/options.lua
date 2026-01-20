-- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/
vim.g.mapleader = ','
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 30


vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
-- word wrap and line indent
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.linebreak = true
-- 启用光标行高亮
vim.opt.cursorline = true

-- 如果你还想开启光标列高亮（可选）
-- vim.opt.cursorcolumn = true

vim.opt.tabstop = 2
-- setting for >>
vim.opt.shiftwidth = 2
-- change all tab into space
vim.opt.expandtab = true

vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',   -- Tab 字符显示为 » 后面跟空格
  trail = '·',  -- 行尾空格显示为点
  extends = '→',
  precedes = '←',
}

vim.opt.shell = "pwsh.exe"
