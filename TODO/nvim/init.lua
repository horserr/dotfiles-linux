-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    'https://github.com/nvim-mini/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- initialize mini deps
require('mini.deps').setup({ path = { package = path_package } })

-- require('core.utils')
require('core.options')
require('core.keymaps')
require('core.autocmds')

local now, later = MiniDeps.now, MiniDeps.later

require('mini.basics').setup({
  options = {
    basic = true,
    extra_ui = true,
    win_ua_line = true, -- 使用统一的状态栏
  },
  -- 快捷键：开启基础快捷键和窗口导航
  mappings = {
    basic = true,
    windows = true,
  },
  -- 自动命令：开启所有基础自动化功能
  autocommands = {
    basic = true,
  }
})
-- ##############
-- statusline, icons, indentscope
-- pairs, surround, comment, cursorword, files, jump2d
-- ##############
-- 1. 立即加载（对界面影响大的）
now(function()
  require('mini.statusline').setup()
  require('mini.icons').setup()
  require('mini.indentscope').setup()
end)

-- 2. 稍后加载（编辑时才用到的功能）
later(function()
  require('mini.pairs').setup()
  -- q for quotes; b for brackets, a for argument, f for function call
  -- _ for punctuation, 1 for digits, space
  -- 1a_1b_c
  require('mini.ai').setup()
  require('mini.operators').setup()

  -- ##############

  require('mini.surround').setup({
    -- 默认快捷键定义（可以保持默认）
    mappings = {
      add = 'sa',            -- Add: 添加符号
      delete = 'sd',         -- Delete: 删除符号
      find = 'sf',           -- Find: 查找符号
      find_left = 'sF',      -- Find left: 向左查找
      highlight = 'sh',      -- Highlight: 高亮符号
      replace = 'sr',        -- Replace: 替换符号
      update_n_lines = 'sn', -- Update n lines: 更新行数
    },
  })
  -- ##############
  require('mini.comment').setup()
  require('mini.cursorword').setup()
  -- ##############
  require('mini.files').setup({
    windows = {
      preview = true,     -- 是否开启文件预览
      width_focus = 30,   -- 聚焦窗口的宽度
      width_preview = 30, -- 预览窗口的宽度
    },
    options = {
      use_as_default_explorer = true, -- 替代原生的 netrw
    },
  }) -- 快捷键通常需要自己定义，例如：
  -- ##############
  local jump2d = require('mini.jump2d')
  jump2d.setup({
    -- 设定标签字母，建议用左手常用键，提高速度
    labels = 'asdfghjklqwertyuiopzxcvbnm',
    view = {
      dim = true, -- 跳转时背景变暗，让目标更显眼
    },
  })

  vim.keymap.set('n', '<leader>s', function()
    jump2d.start(jump2d.builtin_opts.single_character)
  end, { desc = "跳转到指定字符" })

  vim.keymap.set('n', 'f', function()
    jump2d.start(jump2d.builtin_opts.word_start)
  end, { desc = "跳转到单词开头" })

  -- ##############
  -- Pick: files, grep_live/grep, buffers, help
  require('mini.pick').setup( {
  window = {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
    },
  })
  require('mini.extra').setup()
end)

-- add plugins
local add = MiniDeps.add

add({ source = 'catppuccin/nvim', name = 'catppuccin' })

vim.cmd.colorscheme('catppuccin-mocha')
-- vim.cmd.colorscheme('miniwinter')

