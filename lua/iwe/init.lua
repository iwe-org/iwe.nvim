---@class IWE
---@field config IWE.Config
local M = {}

-- Lazy-loaded modules
local config = require('iwe.config')

---Check if the plugin is properly initialized
---@return boolean
local function is_initialized()
  return next(config.get()) ~= nil
end

---Setup the IWE plugin
---@param opts? IWE.Config User configuration options
function M.setup(opts)
  -- Setup configuration first
  config.setup(opts)

  -- Setup core functionality immediately
  require('iwe.commands').setup()
  require('iwe.mappings').setup_plug_mappings()

  -- Setup components that can be loaded immediately
  require('iwe.lsp').setup_autocmds()
  require('iwe.mappings').setup_markdown_mappings()

  -- Setup Telescope integration if enabled
  local telescope_config = config.get().telescope
  if telescope_config.enabled and telescope_config.setup_config then
    require('iwe.telescope').setup()
  end
end

---Get the current configuration
---@return IWE.Config
function M.get_config()
  return config.get()
end

---Get the current IWE project root directory
---@return string|nil Path to IWE project root (directory containing .iwe)
function M.get_project_root()
  return vim.fs.root(0, {'.iwe'})
end

---Check if current buffer/directory is in an IWE project
---@return boolean
function M.is_in_project()
  return M.get_project_root() ~= nil
end

---Start the LSP server
---@param bufnr? number Buffer number (optional)
function M.start_lsp(bufnr)
  require('iwe.lsp').start(bufnr)
end

---Check if LSP server is available
---@return boolean
function M.lsp_available()
  return require('iwe.lsp').is_available()
end


-- Auto-initialization without requiring setup() call
-- This provides smart defaults while still allowing customization
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Only auto-initialize if user hasn't called setup() explicitly
    if not is_initialized() then
      M.setup({})
    end
  end,
  once = true,
  group = vim.api.nvim_create_augroup('IWE_AutoInit', { clear = true }),
  desc = 'Auto-initialize IWE plugin with defaults'
})

return M
