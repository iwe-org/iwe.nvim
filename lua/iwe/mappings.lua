---@class IWE.Mappings
local M = {}

local config = require('iwe.config')

---Setup <Plug> mappings for IWE markdown functionality
function M.setup_plug_mappings()
  local function create_plug_mapping(name, rhs, mode, opts)
    mode = mode or 'n'
    opts = opts or {}
    vim.keymap.set(mode, '<Plug>(iwe-' .. name .. ')', rhs, opts)
  end

  -- Checklist formatting
  create_plug_mapping('checklist-format', ':.g!/- \\[/.s/^/- /<CR>:noh<CR>``', 'n', {
    silent = true,
    desc = 'Format current line as checklist item'
  })

  -- Link navigation
  create_plug_mapping('link-next', '/\\[.*\\](.*)<CR>:noh<CR>', 'n', {
    silent = true,
    desc = 'Navigate to next link'
  })

  create_plug_mapping('link-prev', '?\\[.*\\](.*)<CR>:noh<CR>', 'n', {
    silent = true,
    desc = 'Navigate to previous link'
  })


  -- Date and week abbreviations
  create_plug_mapping('insert-date', function()
    return vim.fn.strftime('%b %d, %Y')
  end, 'i', {
    expr = true,
    desc = 'Insert current date'
  })

  create_plug_mapping('insert-week', function()
    return vim.fn.strftime('Week %V, %Y')
  end, 'i', {
    expr = true,
    desc = 'Insert current week'
  })



  -- Manual LSP start
  create_plug_mapping('lsp-start', function()
    require('iwe.lsp').start()
  end, 'n', {
    silent = true,
    desc = 'Manually start IWE LSP server'
  })

  -- Telescope pickers
  create_plug_mapping('telescope-find-files', function()
    require('iwe.telescope').pickers.find_files()
  end, 'n', {
    silent = true,
    desc = 'Find files (gf equivalent)'
  })

  create_plug_mapping('telescope-paths', function()
    require('iwe.telescope').pickers.paths()
  end, 'n', {
    silent = true,
    desc = 'Workspace symbols - paths (gs equivalent)'
  })

  create_plug_mapping('telescope-roots', function()
    require('iwe.telescope').pickers.roots()
  end, 'n', {
    silent = true,
    desc = 'Namespace symbols - roots (ga equivalent)'
  })

  create_plug_mapping('telescope-backlinks', function()
    require('iwe.telescope').pickers.backlinks()
  end, 'n', {
    silent = true,
    desc = 'LSP references - backlinks (gr equivalent)'
  })

  create_plug_mapping('telescope-headers', function()
    require('iwe.telescope').pickers.headers()
  end, 'n', {
    silent = true,
    desc = 'Document symbols - headers (go equivalent)'
  })

  create_plug_mapping('telescope-grep', function()
    require('iwe.telescope').pickers.grep()
  end, 'n', {
    silent = true,
    desc = 'Live grep search (g/ equivalent)'
  })

  -- LSP action mappings
  create_plug_mapping('lsp-extract-section', function()
    vim.lsp.buf.code_action({apply = true, context = { only = {"refactor.extract.section"}}})
  end, 'n', {
    silent = true,
    desc = 'Extract section (refactor)'
  })

  create_plug_mapping('lsp-inline-reference', function()
    vim.lsp.buf.code_action({apply = true, context = { only = {"refactor.inline.reference"}}})
  end, 'n', {
    silent = true,
    desc = 'Inline reference (refactor)'
  })

  create_plug_mapping('lsp-rewrite-list-section', function()
    vim.lsp.buf.code_action({apply = true, context = { only = {"refactor.rewrite.list.section"}}})
  end, 'n', {
    silent = true,
    desc = 'Rewrite list section (refactor)'
  })

  create_plug_mapping('lsp-rewrite-section-list', function()
    vim.lsp.buf.code_action({apply = true, context = { only = {"refactor.rewrite.section.list"}}})
  end, 'n', {
    silent = true,
    desc = 'Rewrite section list (refactor)'
  })

  create_plug_mapping('lsp-code-action', function()
    vim.lsp.buf.code_action()
  end, 'n', {
    silent = true,
    desc = 'Show code actions'
  })

  create_plug_mapping('lsp-declaration', function()
    vim.lsp.buf.declaration()
  end, 'n', {
    silent = true,
    desc = 'Go to declaration'
  })

  create_plug_mapping('lsp-definition', function()
    vim.lsp.buf.definition()
  end, 'n', {
    silent = true,
    desc = 'Go to definition'
  })

  create_plug_mapping('lsp-implementation', function()
    vim.lsp.buf.implementation()
  end, 'n', {
    silent = true,
    desc = 'Go to implementation'
  })

  create_plug_mapping('lsp-rename', function()
    vim.lsp.buf.rename()
  end, 'n', {
    silent = true,
    desc = 'Rename linked file'
  })

  create_plug_mapping('lsp-diagnostic-prev', function()
    vim.diagnostic.goto_prev()
  end, 'n', {
    silent = true,
    desc = 'Go to previous diagnostic'
  })

  create_plug_mapping('lsp-diagnostic-next', function()
    vim.diagnostic.goto_next()
  end, 'n', {
    silent = true,
    desc = 'Go to next diagnostic'
  })

  create_plug_mapping('lsp-toggle-inlay-hints', function()
    require('iwe.lsp').toggle_inlay_hints()
  end, 'n', {
    silent = true,
    desc = 'Toggle inlay hints'
  })
end

---Setup markdown keymaps (only if enabled in config)
function M.setup_markdown_mappings()
  local opts = config.get()

  if not opts.mappings.enable_markdown_mappings then
    return
  end

  -- Buffer-local mappings for markdown files
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local map_opts = { buffer = buf, silent = true }

      -- Default mappings using <Plug> mappings
      vim.keymap.set('n', '-', '<Plug>(iwe-checklist-format)', map_opts)
      vim.keymap.set('n', '<C-n>', '<Plug>(iwe-link-next)', map_opts)
      vim.keymap.set('n', '<C-p>', '<Plug>(iwe-link-prev)', map_opts)

      -- Insert mode mappings
      vim.keymap.set('i', '/d', '<Plug>(iwe-insert-date)', { buffer = buf })
      vim.keymap.set('i', '/w', '<Plug>(iwe-insert-week)', { buffer = buf })

      -- Telescope keybindings (if enabled)
      if config.get().mappings.enable_telescope_keybindings then
        vim.keymap.set('n', 'gf', '<Plug>(iwe-telescope-find-files)', { buffer = buf })
        vim.keymap.set('n', 'gs', '<Plug>(iwe-telescope-paths)', { buffer = buf })
        vim.keymap.set('n', 'ga', '<Plug>(iwe-telescope-roots)', { buffer = buf })
        vim.keymap.set('n', 'g/', '<Plug>(iwe-telescope-grep)', { buffer = buf })
        vim.keymap.set('n', 'gr', '<Plug>(iwe-telescope-backlinks)', { buffer = buf })
        vim.keymap.set('n', 'go', '<Plug>(iwe-telescope-headers)', { buffer = buf })
      end

      -- LSP keybindings (if enabled)
      if config.get().mappings.enable_lsp_keybindings then
        vim.keymap.set('n', opts.mappings.leader .. 'e', '<Plug>(iwe-lsp-extract-section)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'i', '<Plug>(iwe-lsp-inline-reference)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'h', '<Plug>(iwe-lsp-rewrite-list-section)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'l', '<Plug>(iwe-lsp-rewrite-section-list)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'm', '<Plug>(iwe-lsp-code-action)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'c', '<Plug>(iwe-lsp-rename)', { buffer = buf })
        vim.keymap.set('n', 'gD', '<Plug>(iwe-lsp-declaration)', { buffer = buf })
        vim.keymap.set('n', 'gd', '<Plug>(iwe-lsp-definition)', { buffer = buf })
        vim.keymap.set('n', 'gi', '<Plug>(iwe-lsp-implementation)', { buffer = buf })
        vim.keymap.set('n', '[d', '<Plug>(iwe-lsp-diagnostic-prev)', { buffer = buf })
        vim.keymap.set('n', ']d', '<Plug>(iwe-lsp-diagnostic-next)', { buffer = buf })
        vim.keymap.set('n', '<CR>', '<Plug>(iwe-lsp-definition)', { buffer = buf })
      end
    end,
    group = vim.api.nvim_create_augroup('IWE_MarkdownMappings', { clear = true }),
    desc = 'Setup IWE markdown mappings for markdown files'
  })

  -- Manual LSP start mapping (Neovide only)
  if vim.g.neovide then
    vim.keymap.set('n', '<D-l>', '<Plug>(iwe-lsp-start)', {
      silent = true,
      desc = 'Manually start IWE LSP server'
    })
  end
end

return M
