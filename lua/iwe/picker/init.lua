---@class IWE.Picker
---Public API for picker functionality with backend abstraction
local M = {}

local registry = require("iwe.picker.registry")

---@type boolean
local adapters_loaded = false

---Ensure adapters are loaded
local function ensure_adapters()
  if not adapters_loaded then
    registry.load_adapters()
    adapters_loaded = true
  end
end

---Get the configured backend from config
---@return string|function
local function get_configured_backend()
  local ok, config = pcall(require, "iwe.config")
  if ok then
    local cfg = config.get()
    if cfg.picker and cfg.picker.backend then
      return cfg.picker.backend
    end
  end
  return "auto"
end

---Get the current adapter based on configuration
---@return IWE.Picker.Adapter|nil
local function get_adapter()
  ensure_adapters()

  local backend = get_configured_backend()

  -- Handle custom function backend
  if type(backend) == "function" then
    return {
      name = "custom",
      is_available = function() return true end,
      find_files = function(opts) backend("find_files", opts) end,
      grep = function(opts) backend("grep", opts) end,
      lsp_workspace_symbols = function(opts) backend("lsp_workspace_symbols", opts) end,
      lsp_document_symbols = function(opts) backend("lsp_document_symbols", opts) end,
      lsp_references = function(opts) backend("lsp_references", opts) end,
    }
  end

  -- Handle auto detection
  if backend == "auto" then
    local detected = registry.detect()
    if detected then
      return registry.get(detected)
    end
    return nil
  end

  -- Handle specific backend
  if registry.is_available(backend) then
    return registry.get(backend)
  end

  -- Fallback notification
  local ok_cfg, config = pcall(require, "iwe.config")
  if ok_cfg then
    local cfg = config.get()
    if cfg.picker and cfg.picker.fallback_notify then
      vim.notify(
        string.format("Picker backend '%s' not available, using fallback", backend),
        vim.log.levels.WARN
      )
    end
  end

  -- Try auto-detect as fallback
  local detected = registry.detect()
  if detected then
    return registry.get(detected)
  end

  return nil
end

---Check if any picker is available
---@return boolean
function M.is_available()
  ensure_adapters()
  return registry.detect() ~= nil
end

---Get the current backend name
---@return string|nil
function M.get_backend()
  ensure_adapters()

  local backend = get_configured_backend()

  if type(backend) == "function" then
    return "custom"
  end

  if backend == "auto" then
    return registry.detect()
  end

  if registry.is_available(backend) then
    return backend
  end

  return registry.detect()
end

---Find files picker
---@param opts? table Options
function M.find_files(opts)
  local adapter = get_adapter()
  if adapter then
    adapter.find_files(opts)
  else
    vim.notify("No picker backend available", vim.log.levels.ERROR)
  end
end

---Live grep
---@param opts? table Options
function M.grep(opts)
  local adapter = get_adapter()
  if adapter then
    adapter.grep(opts)
  else
    vim.notify("No picker backend available", vim.log.levels.ERROR)
  end
end

---Workspace symbols (paths)
---@param opts? table Options
function M.paths(opts)
  opts = opts or {}
  opts.prompt_title = opts.prompt_title or "IWE Paths"

  local adapter = get_adapter()
  if adapter then
    adapter.lsp_workspace_symbols(opts)
  else
    vim.notify("No picker backend available", vim.log.levels.ERROR)
  end
end

---Namespace symbols (roots)
---@param opts? table Options
function M.roots(opts)
  opts = opts or {}
  opts.prompt_title = opts.prompt_title or "IWE Roots"
  opts.symbols = { "namespace" }

  local adapter = get_adapter()
  if adapter then
    adapter.lsp_workspace_symbols(opts)
  else
    vim.notify("No picker backend available", vim.log.levels.ERROR)
  end
end

---Document symbols (headers)
---@param opts? table Options
function M.headers(opts)
  opts = opts or {}
  opts.prompt_title = opts.prompt_title or "IWE Headers"

  local adapter = get_adapter()
  if adapter then
    adapter.lsp_document_symbols(opts)
  else
    vim.notify("No picker backend available", vim.log.levels.ERROR)
  end
end

---Block references (LSP references without declaration)
---@param opts? table Options
function M.blockreferences(opts)
  opts = opts or {}
  opts.prompt_title = opts.prompt_title or "IWE Block References"
  opts.include_declaration = false

  local adapter = get_adapter()
  if adapter then
    adapter.lsp_references(opts)
  else
    vim.notify("No picker backend available", vim.log.levels.ERROR)
  end
end

---Backlinks (LSP references with declaration)
---@param opts? table Options
function M.backlinks(opts)
  opts = opts or {}
  opts.prompt_title = opts.prompt_title or "IWE Backlinks"
  opts.include_declaration = true

  local adapter = get_adapter()
  if adapter then
    adapter.lsp_references(opts)
  else
    vim.notify("No picker backend available", vim.log.levels.ERROR)
  end
end

---Get list of available backends
---@return string[]
function M.list_backends()
  ensure_adapters()
  return registry.list_available()
end

return M
