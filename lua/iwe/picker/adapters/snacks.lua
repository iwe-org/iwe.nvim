---@class IWE.Picker.Adapters.Snacks
---Snacks.nvim picker adapter
local M = {}

M.name = "snacks"

---Check if Snacks picker is available
---@return boolean
function M.is_available()
  local ok, snacks = pcall(require, "snacks")
  return ok and snacks.picker ~= nil
end

---Find files with Snacks picker
---@param opts? table Options
function M.find_files(opts)
  if not M.is_available() then
    vim.notify("Snacks picker not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("snacks").picker.files(opts)
end

---Live grep with Snacks picker
---@param opts? table Options
function M.grep(opts)
  if not M.is_available() then
    vim.notify("Snacks picker not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("snacks").picker.grep(opts)
end

---LSP workspace symbols with Snacks picker
---@param opts? table Options (symbols: string[] for filtering, prompt_title: string)
function M.lsp_workspace_symbols(opts)
  if not M.is_available() then
    vim.notify("Snacks picker not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  local snacks_opts = {
    title = opts.prompt_title or "Workspace Symbols",
  }

  -- Filter by symbol kind if specified
  if opts.symbols then
    snacks_opts.filter = {
      kind = opts.symbols,
    }
  end

  require("snacks").picker.lsp_workspace_symbols(snacks_opts)
end

---LSP document symbols with Snacks picker
---@param opts? table Options
function M.lsp_document_symbols(opts)
  if not M.is_available() then
    vim.notify("Snacks picker not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("snacks").picker.lsp_symbols({
    title = opts.prompt_title or "Document Symbols",
  })
end

---LSP references with Snacks picker
---@param opts? table Options (include_declaration: boolean, prompt_title: string)
function M.lsp_references(opts)
  if not M.is_available() then
    vim.notify("Snacks picker not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  local include_declaration = opts.include_declaration
  if include_declaration == nil then
    include_declaration = true
  end

  require("snacks").picker.lsp_references({
    title = opts.prompt_title or "References",
    include_declaration = include_declaration,
  })
end

return M
