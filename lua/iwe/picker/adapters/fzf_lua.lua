---@class IWE.Picker.Adapters.FzfLua
---fzf-lua adapter for picker functionality
local M = {}

M.name = "fzf_lua"

---Check if fzf-lua is available
---@return boolean
function M.is_available()
  return pcall(require, "fzf-lua")
end

---Find files with fzf-lua
---@param opts? table Options
function M.find_files(opts)
  if not M.is_available() then
    vim.notify("fzf-lua not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("fzf-lua").files(opts)
end

---Live grep with fzf-lua
---@param opts? table Options
function M.grep(opts)
  if not M.is_available() then
    vim.notify("fzf-lua not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("fzf-lua").live_grep(opts)
end

---LSP workspace symbols with fzf-lua
---@param opts? table Options (symbols: string[] for filtering, prompt_title: string)
function M.lsp_workspace_symbols(opts)
  if not M.is_available() then
    vim.notify("fzf-lua not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  local fzf_opts = {
    prompt = (opts.prompt_title or "Workspace Symbols") .. "> ",
  }

  -- Filter by symbol kind if specified
  if opts.symbols then
    fzf_opts.symbols = opts.symbols
  end

  require("fzf-lua").lsp_workspace_symbols(fzf_opts)
end

---LSP document symbols with fzf-lua
---@param opts? table Options
function M.lsp_document_symbols(opts)
  if not M.is_available() then
    vim.notify("fzf-lua not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("fzf-lua").lsp_document_symbols({
    prompt = (opts.prompt_title or "Document Symbols") .. "> ",
  })
end

---LSP references with fzf-lua
---@param opts? table Options (include_declaration: boolean, prompt_title: string)
function M.lsp_references(opts)
  if not M.is_available() then
    vim.notify("fzf-lua not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  local include_declaration = opts.include_declaration
  if include_declaration == nil then
    include_declaration = true
  end

  require("fzf-lua").lsp_references({
    prompt = (opts.prompt_title or "References") .. "> ",
    includeDeclaration = include_declaration,
  })
end

return M
