---@class IWE.LSP
local M = {}

local config = require('iwe.config')

---Check if iwes LSP server is available
---@return boolean
function M.is_available()
  return vim.fn.executable('iwes') == 1
end

---Toggle inlay hints for the current buffer
---@param bufnr? number Buffer number (defaults to current buffer)
function M.toggle_inlay_hints(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not vim.lsp.inlay_hint then
    vim.notify("Inlay hints not available in this Neovim version", vim.log.levels.WARN)
    return
  end

  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })

  local status = enabled and "disabled" or "enabled"
  vim.notify(string.format("Inlay hints %s", status), vim.log.levels.INFO)
end

---Start the IWE LSP server for the current buffer
---@param bufnr? number Buffer number (defaults to current buffer)
function M.start(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not M.is_available() then
    vim.notify("iwes LSP server not found in PATH", vim.log.levels.WARN)
    return
  end

  local opts = config.get()

  vim.lsp.start({
    name = opts.lsp.name,
    cmd = opts.lsp.cmd,
    root_dir = vim.fs.root(bufnr, {'.iwe'}),
    flags = {
      debounce_text_changes = opts.lsp.debounce_text_changes
    }
  }, {
    bufnr = bufnr
  })
end

---Setup LSP autocommands
function M.setup_autocmds()
  local opts = config.get()

  -- Auto-start LSP for markdown files with .iwe marker
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function(args)
      if vim.fs.root(args.buf, {'.iwe'}) then
        M.start(args.buf)
      end
    end,
    group = vim.api.nvim_create_augroup('IWE_LSP_Start', { clear = true }),
    desc = 'Start IWE LSP server for markdown files'
  })

  -- Setup LSP attach behavior
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("IWE_LSP_Attach", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == opts.lsp.name then
        -- Enable inlay hints if configured and supported
        if opts.lsp.enable_inlay_hints and vim.lsp.inlay_hint and client:supports_method('textDocument/inlayHint') then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end

        -- Setup auto-formatting on save if enabled
        if opts.lsp.auto_format_on_save then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ async = false, id = args.data.client_id })

              -- Disable RenderMarkdown temporarily during format
              if vim.fn.exists(':RenderMarkdown') > 0 then
                vim.cmd('RenderMarkdown disable')

                local timer = vim.uv.new_timer()
                if timer then
                  timer:start(150, 0, vim.schedule_wrap(function()
                    vim.cmd('RenderMarkdown enable')
                    timer:close()
                  end))
                end
              end
            end,
            group = vim.api.nvim_create_augroup('IWE_LSP_Format_' .. args.buf, { clear = true }),
            desc = 'Format IWE markdown on save'
          })
        end
      end
    end,
    desc = 'Setup IWE LSP features on attach'
  })
end

return M
