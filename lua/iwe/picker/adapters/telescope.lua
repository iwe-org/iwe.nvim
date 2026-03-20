---@class IWE.Picker.Adapters.Telescope
---Telescope adapter for picker functionality
local M = {}

M.name = "telescope"

---Check if Telescope is available
---@return boolean
function M.is_available()
  return pcall(require, "telescope")
end

---Default layout config for IWE pickers
local function get_layout_config()
  return {
    horizontal = {
      prompt_position = "top",
      preview_width = 0.7,
      width = 0.9,
      height = 0.9,
    },
  }
end

---Find files with Telescope
---@param opts? table Options
function M.find_files(opts)
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("telescope.builtin").find_files(vim.tbl_extend("force", {
    layout_config = get_layout_config(),
  }, opts))
end

---Live grep with Telescope
---@param opts? table Options
function M.grep(opts)
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("telescope.builtin").live_grep(vim.tbl_extend("force", {
    prompt_title = "Live Grep",
    layout_config = get_layout_config(),
  }, opts))
end

local function make_lsp_symbol_entry_maker(opts)
  local entry_display = require("telescope.pickers.entry_display")

  opts = opts or {}
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = opts.symbol_width or 100 },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.symbol_name,
    })
  end

  return function(entry)
    if not entry then
      return nil
    end

    local symbol_type, symbol_name = entry.text:match("%[(.+)%]%s+(.*)")
    symbol_name = symbol_name or entry.text

    return {
      value = entry,
      ordinal = symbol_name .. " " .. (symbol_type or ""),
      display = make_display,
      filename = entry.filename,
      lnum = entry.lnum,
      col = entry.col,
      symbol_name = symbol_name,
      symbol_type = symbol_type,
    }
  end
end

---LSP workspace symbols with Telescope
---@param opts? table Options (symbols: string[] for filtering, prompt_title: string)
function M.lsp_workspace_symbols(opts)
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  local picker_opts = vim.tbl_extend("force", {
    prompt_title = opts.prompt_title or "Workspace Symbols",
    fname_width = 0,
    symbol_width = 100,
    layout_config = {
      horizontal = {
        preview_width = 0.5,
        width = 0.9,
        height = 0.9,
      },
    },
  }, opts)

  picker_opts.entry_maker = make_lsp_symbol_entry_maker(picker_opts)
  require("telescope.builtin").lsp_dynamic_workspace_symbols(picker_opts)
end

---LSP document symbols with Telescope
---@param opts? table Options
function M.lsp_document_symbols(opts)
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  require("telescope.builtin").lsp_document_symbols(vim.tbl_extend("force", {
    prompt_title = opts.prompt_title or "Document Symbols",
    layout_config = get_layout_config(),
  }, opts))
end

---LSP references with Telescope
---@param opts? table Options (include_declaration: boolean, prompt_title: string)
function M.lsp_references(opts)
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}
  local include_declaration = opts.include_declaration
  if include_declaration == nil then
    include_declaration = true
  end

  require("telescope.builtin").lsp_references(vim.tbl_extend("force", {
    prompt_title = opts.prompt_title or "References",
    include_declaration = include_declaration,
    layout_config = get_layout_config(),
  }, opts))
end

return M
