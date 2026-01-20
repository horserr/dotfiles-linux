local utils = require('core.utils')
--
-- keybindings
-- n: Normal mode.
-- i: Insert mode.
-- x: Visual mode.
-- s: Selection mode.
-- v: Visual + Selection.
-- t: Terminal mode.
-- o: Operator-pending.
-- '': Yes, an empty string. Is the equivalent of n + v + o.

local map = vim.keymap

map.set('i', ';a', '+', { silent = true })
map.set('i', ';s', '-', { silent = true })
map.set('i', ';e', '=', { silent = true })
map.set('i', ';l', '_', { silent = true })
map.set('i', ';f', '(', { silent = true })
map.set('i', ';v', '{', { silent = true })
map.set('i', ';b', '[', { silent = true })

-- ignore cut results
map.set({'n', 'x'}, 'x', '"_x')
map.set({'n', 'x'}, 'X', '"_d')

map.set("n", "<space>X", utils.open_file_dir, { desc = "在系统文件管理器中打开当前目录" })

-- 在插入模式下按 Tab，如果后面是括号/引号就跳出，否则输入正常的 Tab
map.set('i', '<Tab>', function()
  local col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local char = line:sub(col, col)
  local closers = { ')', ']', '}', '>', '"', "'", '`' }

  for _, closer in ipairs(closers) do
    if char == closer then
      return "<Right>"
    end
  end
  return "<Tab>"
end, { expr = true, silent = true })

map.set('n', '<space>f', '<cmd>Pick files<cr>', { desc = '模糊搜索文件名' })
map.set('n', '<space>F', '<cmd>Pick grep_live<cr>', { desc = '实时搜索代码内容' })
map.set('n', '<space>r', '<cmd>Pick buffers<cr>', { desc = '搜索已打开的缓冲区' })

vim.keymap.set('n', '<space>x', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local path = vim.fn.filereadable(bufname) == 1 and bufname or vim.fn.getcwd()
  MiniFiles.open(path)
end, { desc = "打开文件浏览器" })

