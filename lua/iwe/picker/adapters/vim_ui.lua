---@class IWE.Picker.Adapters.VimUI
---vim.ui.select fallback adapter for picker functionality
local M = {}

M.name = "vim_ui"

---Check if vim.ui.select is available (always true)
---@return boolean
function M.is_available()
  return true
end

---Navigate to a location
---@param item {filename: string, lnum: number, col: number}
local function goto_location(item)
  if item.filename then
    vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
  end
  if item.lnum then
    vim.api.nvim_win_set_cursor(0, { item.lnum, (item.col or 1) - 1 })
  end
end

---Format an LSP symbol for display
---@param symbol table LSP symbol
---@param bufnr number Buffer number
---@return string formatted display string
---@return table location info for navigation
local function format_symbol(symbol, bufnr)
  local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Unknown"
  local name = symbol.name or ""
  local display = string.format("[%s] %s", kind, name)

  local location = symbol.location or symbol
  local range = location.range or (location.selectionRange or location)

  local filename
  if location.uri then
    filename = vim.uri_to_fname(location.uri)
  else
    filename = vim.api.nvim_buf_get_name(bufnr)
  end

  local lnum = 1
  local col = 1
  if range and range.start then
    lnum = range.start.line + 1
    col = range.start.character + 1
  end

  return display, { filename = filename, lnum = lnum, col = col }
end

---Format an LSP reference for display
---@param ref table LSP reference
---@return string formatted display string
---@return table location info for navigation
local function format_reference(ref)
  local filename = vim.uri_to_fname(ref.uri)
  local range = ref.range
  local lnum = range.start.line + 1
  local col = range.start.character + 1

  -- Try to get line preview
  local preview = ""
  local lines = vim.fn.readfile(filename, "", lnum)
  if lines and #lines > 0 then
    preview = vim.trim(lines[#lines])
    if #preview > 50 then
      preview = preview:sub(1, 47) .. "..."
    end
  end

  local short_filename = vim.fn.fnamemodify(filename, ":~:.")
  local display = string.format("%s:%d: %s", short_filename, lnum, preview)

  return display, { filename = filename, lnum = lnum, col = col }
end

---Find files picker - not supported via vim.ui.select
---@param _opts? table Options (unused)
function M.find_files(_opts)
  vim.notify(
    "File picker requires a fuzzy finder (telescope, fzf-lua, snacks, or mini.pick). Use :edit or :find instead.",
    vim.log.levels.INFO
  )
end

---Live grep - not supported via vim.ui.select
---@param _opts? table Options (unused)
function M.grep(_opts)
  vim.notify(
    "Live grep requires a fuzzy finder (telescope, fzf-lua, snacks, or mini.pick). Use :vimgrep or :grep instead.",
    vim.log.levels.INFO
  )
end

---LSP workspace symbols via vim.ui.select
---@param opts? table Options (symbols: string[] for filtering)
function M.lsp_workspace_symbols(opts)
  opts = opts or {}
  local query = opts.query or ""
  local symbol_filter = opts.symbols

  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end

  local params = { query = query }
  vim.lsp.buf_request(bufnr, "workspace/symbol", params, function(err, result, _, _)
    if err then
      vim.notify("LSP error: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    if not result or #result == 0 then
      vim.notify("No symbols found", vim.log.levels.INFO)
      return
    end

    -- Filter by symbol type if specified
    if symbol_filter then
      local filter_set = {}
      for _, s in ipairs(symbol_filter) do
        filter_set[s:lower()] = true
      end
      result = vim.tbl_filter(function(sym)
        local kind_name = vim.lsp.protocol.SymbolKind[sym.kind]
        return kind_name and filter_set[kind_name:lower()]
      end, result)
    end

    if #result == 0 then
      vim.notify("No matching symbols found", vim.log.levels.INFO)
      return
    end

    -- Build items for selection
    local items = {}
    local locations = {}
    for i, symbol in ipairs(result) do
      local display, location = format_symbol(symbol, bufnr)
      table.insert(items, display)
      locations[i] = location
    end

    vim.ui.select(items, {
      prompt = opts.prompt_title or "Workspace Symbols",
    }, function(choice, idx)
      if choice and idx then
        goto_location(locations[idx])
      end
    end)
  end)
end

---LSP document symbols via vim.ui.select
---@param opts? table Options
function M.lsp_document_symbols(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, result, _, _)
    if err then
      vim.notify("LSP error: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    if not result or #result == 0 then
      vim.notify("No symbols found", vim.log.levels.INFO)
      return
    end

    -- Flatten nested symbols
    local flat_symbols = {}
    local function flatten(symbols, prefix)
      for _, symbol in ipairs(symbols) do
        local name = prefix and (prefix .. " > " .. symbol.name) or symbol.name
        table.insert(flat_symbols, vim.tbl_extend("force", symbol, { name = name }))
        if symbol.children then
          flatten(symbol.children, name)
        end
      end
    end
    flatten(result, nil)

    -- Build items for selection
    local items = {}
    local locations = {}
    for i, symbol in ipairs(flat_symbols) do
      local display, location = format_symbol(symbol, bufnr)
      table.insert(items, display)
      locations[i] = location
    end

    vim.ui.select(items, {
      prompt = opts.prompt_title or "Document Symbols",
    }, function(choice, idx)
      if choice and idx then
        goto_location(locations[idx])
      end
    end)
  end)
end

---LSP references via vim.ui.select
---@param opts? table Options (include_declaration: boolean)
function M.lsp_references(opts)
  opts = opts or {}
  local include_declaration = opts.include_declaration
  if include_declaration == nil then
    include_declaration = true
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = include_declaration }

  vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result, _, _)
    if err then
      vim.notify("LSP error: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    if not result or #result == 0 then
      vim.notify("No references found", vim.log.levels.INFO)
      return
    end

    -- Build items for selection
    local items = {}
    local locations = {}
    for i, ref in ipairs(result) do
      local display, location = format_reference(ref)
      table.insert(items, display)
      locations[i] = location
    end

    vim.ui.select(items, {
      prompt = opts.prompt_title or "References",
    }, function(choice, idx)
      if choice and idx then
        goto_location(locations[idx])
      end
    end)
  end)
end

return M
