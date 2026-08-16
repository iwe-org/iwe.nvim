---@class IWE
---@field config IWE.Config
local M = {}

-- Lazy-loaded modules
local config = require('iwe.config')

---Setup the IWE plugin
---@param opts? IWE.Config User configuration options
function M.setup(opts)
  -- Setup configuration first
  config.setup(opts)

  -- Setup core functionality immediately
  require('iwe.commands').setup()
  require('iwe.mappings').setup_plug_mappings()

  -- Enable the IWE LSP server via Neovim's built-in config (lsp/iwes.lua).
  -- Attaches automatically to markdown buffers inside a `.iwe` project.
  if vim.fn.has('nvim-0.11.2') == 1 then
    vim.lsp.enable('iwes')
  else
    vim.notify(
      'iwe.nvim: LSP integration requires Neovim 0.11.2 or later',
      vim.log.levels.WARN
    )
  end

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

return M
