-- Minimal init file for testing
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/site]])

-- Add plugin to runtime path
local plugin_path = vim.fn.expand('<sfile>:p:h:h')
vim.opt.rtp:prepend(plugin_path)

-- Add plenary to runtime path (for testing)
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/site/pack/vendor/start/plenary.nvim')
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/site/pack/vendor/start/telescope.nvim')

-- Basic vim settings for testing
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false
vim.opt.writebackup = false

-- Load the plugin
require('iwe').setup({
  -- Test configuration
  lsp = {
    cmd = { 'echo', 'mock-iwes' }, -- Mock iwes command for testing
  },
  mappings = {
    enable_markdown_mappings = true,
    enable_telescope_keybindings = false,
    enable_lsp_keybindings = false,
  },
  telescope = {
    enabled = true,
    setup_config = false, -- Don't setup telescope config in tests
    load_extensions = {}, -- No extensions in tests
  },
})