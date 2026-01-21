---@class IWE.Picker.Registry
---Manages picker adapter detection and selection
local M = {}

---@alias IWE.Picker.BackendName "telescope"|"fzf_lua"|"snacks"|"mini"|"vim_ui"

---@class IWE.Picker.Adapter
---@field name string Adapter name
---@field is_available fun(): boolean Check if adapter is available
---@field find_files fun(opts?: table) File picker
---@field grep fun(opts?: table) Live grep
---@field lsp_workspace_symbols fun(opts?: table) Workspace symbols (for paths/roots)
---@field lsp_document_symbols fun(opts?: table) Document symbols (for headers)
---@field lsp_references fun(opts?: table) LSP references (for blockreferences/backlinks)

---Priority order for auto-detection
---@type IWE.Picker.BackendName[]
M.priority = { "telescope", "fzf_lua", "snacks", "mini", "vim_ui" }

---Registered adapters
---@type table<IWE.Picker.BackendName, IWE.Picker.Adapter>
M.adapters = {}

---Register an adapter
---@param name IWE.Picker.BackendName
---@param adapter IWE.Picker.Adapter
function M.register(name, adapter)
  M.adapters[name] = adapter
end

---Get adapter by name
---@param name IWE.Picker.BackendName
---@return IWE.Picker.Adapter|nil
function M.get(name)
  return M.adapters[name]
end

---Check if a specific backend is available
---@param name IWE.Picker.BackendName
---@return boolean
function M.is_available(name)
  local adapter = M.adapters[name]
  return adapter ~= nil and adapter.is_available()
end

---Get the first available backend based on priority
---@return IWE.Picker.BackendName|nil
function M.detect()
  for _, name in ipairs(M.priority) do
    if M.is_available(name) then
      return name
    end
  end
  return nil
end

---Get list of all available backends
---@return IWE.Picker.BackendName[]
function M.list_available()
  local available = {}
  for _, name in ipairs(M.priority) do
    if M.is_available(name) then
      table.insert(available, name)
    end
  end
  return available
end

---Load all adapters
function M.load_adapters()
  -- Load each adapter module which will self-register
  local adapter_names = { "telescope", "fzf_lua", "snacks", "mini", "vim_ui" }
  for _, name in ipairs(adapter_names) do
    local ok, adapter = pcall(require, "iwe.picker.adapters." .. name)
    if ok and adapter then
      M.register(name, adapter)
    end
  end
end

return M
