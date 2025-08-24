---@class IWE.Config
---@field lsp IWE.Config.LSP LSP server configuration
---@field mappings IWE.Config.Mappings Key mapping configuration
---@field telescope IWE.Config.Telescope Telescope integration configuration


---@class IWE.Config.LSP
---@field cmd string[] Command to start the LSP server
---@field name string Name of the LSP server
---@field debounce_text_changes number Debounce time for text changes
---@field auto_format_on_save boolean Whether to format on save
---@field enable_inlay_hints boolean Whether to enable inlay hints

---@class IWE.Config.Mappings
---@field enable_markdown_mappings boolean Whether to enable core markdown editing key mappings
---@field enable_telescope_keybindings boolean Whether to enable telescope keybindings (gf, gs, ga, etc.)
---@field enable_lsp_keybindings boolean Whether to enable LSP keybindings (gd, gr, <leader>e, etc.)
---@field leader string Leader key for mappings
---@field localleader string Local leader key for mappings

---@class IWE.Config.Telescope
---@field enabled boolean Whether to enable Telescope integration
---@field setup_config boolean Whether to setup Telescope config automatically
---@field load_extensions string[] Extensions to load automatically

local M = {}

---@type IWE.Config
M.defaults = {
  lsp = {
    cmd = { "iwes" },
    name = "iwes",
    debounce_text_changes = 500,
    auto_format_on_save = true,
    enable_inlay_hints = true
  },
  mappings = {
    enable_markdown_mappings = true,
    enable_telescope_keybindings = false,
    enable_lsp_keybindings = false,
    leader = "<leader>",
    localleader = "<localleader>"
  },
  telescope = {
    enabled = true,
    setup_config = true,
    load_extensions = { "ui-select", "emoji" }
  }
}

---@type IWE.Config
M.options = {}

---Validate configuration options
---@param opts IWE.Config
---@return boolean success
---@return string? error
local function validate_config(opts)
  if opts.lsp then
    if opts.lsp.cmd and type(opts.lsp.cmd) ~= "table" then
      return false, "lsp.cmd must be an array"
    end
    if opts.lsp.name and type(opts.lsp.name) ~= "string" then
      return false, "lsp.name must be a string"
    end
    if opts.lsp.debounce_text_changes and type(opts.lsp.debounce_text_changes) ~= "number" then
      return false, "lsp.debounce_text_changes must be a number"
    end
  end

  if opts.telescope then
    if opts.telescope.enabled ~= nil and type(opts.telescope.enabled) ~= "boolean" then
      return false, "telescope.enabled must be a boolean"
    end
    if opts.telescope.setup_config ~= nil and type(opts.telescope.setup_config) ~= "boolean" then
      return false, "telescope.setup_config must be a boolean"
    end
    if opts.telescope.load_extensions and type(opts.telescope.load_extensions) ~= "table" then
      return false, "telescope.load_extensions must be an array"
    end
  end

  return true, nil
end

---Setup configuration with user options
---@param opts? IWE.Config User configuration options
function M.setup(opts)
  opts = opts or {}

  local success, error = validate_config(opts)
  if not success then
    vim.notify(string.format("IWE configuration error: %s", error), vim.log.levels.ERROR)
    return
  end

  M.options = vim.tbl_deep_extend("force", M.defaults, opts)
end

---Get current configuration
---@return IWE.Config
function M.get()
  return M.options
end

---Get a specific configuration value
---@param key string Dot-separated key path (e.g., "paths.iwe_project")
---@return any
function M.get_value(key)
  local keys = vim.split(key, ".", { plain = true })
  local value = M.options

  for _, k in ipairs(keys) do
    if type(value) ~= "table" or value[k] == nil then
      return nil
    end
    value = value[k]
  end

  return value
end

return M
