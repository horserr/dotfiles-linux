-- lua/core/autocmds.lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 保存时自动去除行尾空格
local trim_whitespace = augroup('TrimWhitespace', { clear = true })
autocmd('BufWritePre', {
  group = trim_whitespace,
  pattern = '*',
  callback = function()
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- 打开文件时自动恢复光标位置
local restore_cursor = augroup('RestoreCursor', { clear = true })
autocmd('BufReadPost', {
  group = restore_cursor,
  pattern = '*',
  callback = function()
    if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd([[normal! g`"]])
    end
  end,
})

-- 创建一个自动命令，专门针对 mini.files 的缓冲区设置快捷键
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id
    -- 绑定 'Enter' 键为同步（保存）操作
    -- 这样你改完名字直接按回车就能保存，不需要 Ctrl+s
    vim.keymap.set('n', '<CR>', MiniFiles.synchronize, { buffer = buf_id, desc = "同步文件改动" })

    -- 如果你还是想用 Ctrl+s，也可以在这里显式重新绑定一次
    vim.keymap.set('n', '<C-s>', MiniFiles.synchronize, { buffer = buf_id, desc = "同步文件改动" })
  end,
})

-- 只在当前活动的窗口显示光标行，而在切换到其他窗口时自动隐藏
local cursorline_group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = cursorline_group,
  pattern = "*",
  command = "set cursorline",
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
  group = cursorline_group,
  pattern = "*",
  command = "set nocursorline",
})
