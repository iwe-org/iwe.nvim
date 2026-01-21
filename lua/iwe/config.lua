---@class IWE.Config
---@field lsp IWE.Config.LSP LSP server configuration
---@field mappings IWE.Config.Mappings Key mapping configuration
---@field picker IWE.Config.Picker Picker backend configuration
---@field telescope IWE.Config.Telescope Telescope integration configuration (deprecated, use picker)
---@field preview IWE.Config.Preview Preview generation configuration


---@class IWE.Config.LSP
---@field cmd string[] Command to start the LSP server
---@field name string Name of the LSP server
---@field debounce_text_changes number Debounce time for text changes
---@field auto_format_on_save boolean Whether to format on save
---@field enable_inlay_hints boolean Whether to enable inlay hints

---@class IWE.Config.Mappings
---@field enable_markdown_mappings boolean Whether to enable core markdown editing key mappings
---@field enable_picker_keybindings boolean Whether to enable picker keybindings (gf, gs, ga, etc.)
---@field enable_telescope_keybindings boolean Deprecated alias for enable_picker_keybindings
---@field enable_lsp_keybindings boolean Whether to enable IWE-specific LSP keybindings
---@field enable_preview_keybindings boolean Whether to enable preview keybindings
---@field leader string Leader key for mappings
---@field localleader string Local leader key for mappings

---@class IWE.Config.Picker
---@field backend string|function Backend: "auto", "telescope", "fzf_lua", "snacks", "mini", "vim_ui", or function
---@field fallback_notify boolean Whether to notify when falling back to another backend

---@class IWE.Config.Telescope
---@field enabled boolean Whether to enable Telescope integration
---@field setup_config boolean Whether to setup Telescope config automatically
---@field load_extensions string[] Extensions to load automatically

---@class IWE.Config.Preview
---@field output_dir string Directory for generated preview files
---@field temp_dir string Directory for temporary files during preview generation
---@field auto_open boolean Whether to automatically open generated previews

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
    enable_picker_keybindings = false,
    enable_telescope_keybindings = false, -- deprecated alias
    enable_lsp_keybindings = false,
    enable_preview_keybindings = false,
    leader = "<leader>",
    localleader = "<localleader>"
  },
  picker = {
    backend = "auto",
    fallback_notify = true,
  },
  telescope = {
    enabled = true,
    setup_config = true,
    load_extensions = { "ui-select", "emoji" }
  },
  preview = {
    output_dir = vim.fn.expand("~/tmp/preview"),
    temp_dir = vim.fn.expand("/tmp"),
    auto_open = false
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

  if opts.preview then
    if opts.preview.output_dir and type(opts.preview.output_dir) ~= "string" then
      return false, "preview.output_dir must be a string"
    end
    if opts.preview.temp_dir and type(opts.preview.temp_dir) ~= "string" then
      return false, "preview.temp_dir must be a string"
    end
    if opts.preview.auto_open ~= nil and type(opts.preview.auto_open) ~= "boolean" then
      return false, "preview.auto_open must be a boolean"
    end
  end

  if opts.picker then
    if opts.picker.backend ~= nil then
      local backend = opts.picker.backend
      local valid_backends = { "auto", "telescope", "fzf_lua", "snacks", "mini", "vim_ui" }
      if type(backend) ~= "function" and type(backend) ~= "string" then
        return false, "picker.backend must be a string or function"
      end
      if type(backend) == "string" and not vim.tbl_contains(valid_backends, backend) then
        local valid_str = table.concat(valid_backends, ", ")
        return false, string.format("picker.backend must be one of: %s, or a function", valid_str)
      end
    end
    if opts.picker.fallback_notify ~= nil and type(opts.picker.fallback_notify) ~= "boolean" then
      return false, "picker.fallback_notify must be a boolean"
    end
  end

  return true, nil
end

---Setup configuration with user options
---@param opts? IWE.Config User configuration options
function M.setup(opts)
  opts = opts or {}

  local success, err = validate_config(opts)
  if not success then
    vim.notify(string.format("IWE configuration error: %s", err), vim.log.levels.ERROR)
    return
  end

  M.options = vim.tbl_deep_extend("force", M.defaults, opts)

  -- Handle deprecated enable_telescope_keybindings option
  if M.options.mappings then
    if M.options.mappings.enable_telescope_keybindings and not M.options.mappings.enable_picker_keybindings then
      M.options.mappings.enable_picker_keybindings = M.options.mappings.enable_telescope_keybindings
    end
  end
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
