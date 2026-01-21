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

  -- Picker mappings (new, backend-agnostic)
  create_plug_mapping('picker-find-files', function()
    require('iwe.picker').find_files()
  end, 'n', {
    silent = true,
    desc = 'Find files (gf equivalent)'
  })

  create_plug_mapping('picker-paths', function()
    require('iwe.picker').paths()
  end, 'n', {
    silent = true,
    desc = 'Workspace symbols - paths (gs equivalent)'
  })

  create_plug_mapping('picker-roots', function()
    require('iwe.picker').roots()
  end, 'n', {
    silent = true,
    desc = 'Namespace symbols - roots (ga equivalent)'
  })

  create_plug_mapping('picker-blockreferences', function()
    require('iwe.picker').blockreferences()
  end, 'n', {
    silent = true,
    desc = 'LSP references - blockreferences (gb equivalent)'
  })

  create_plug_mapping('picker-backlinks', function()
    require('iwe.picker').backlinks()
  end, 'n', {
    silent = true,
    desc = 'LSP references - backlinks (gR equivalent)'
  })

  create_plug_mapping('picker-headers', function()
    require('iwe.picker').headers()
  end, 'n', {
    silent = true,
    desc = 'Document symbols - headers (go equivalent)'
  })

  create_plug_mapping('picker-grep', function()
    require('iwe.picker').grep()
  end, 'n', {
    silent = true,
    desc = 'Live grep search (g/ equivalent)'
  })

  -- Backward compatibility aliases (deprecated telescope- prefixed mappings)
  vim.keymap.set('n', '<Plug>(iwe-telescope-find-files)', '<Plug>(iwe-picker-find-files)', { remap = true })
  vim.keymap.set('n', '<Plug>(iwe-telescope-paths)', '<Plug>(iwe-picker-paths)', { remap = true })
  vim.keymap.set('n', '<Plug>(iwe-telescope-roots)', '<Plug>(iwe-picker-roots)', { remap = true })
  vim.keymap.set('n', '<Plug>(iwe-telescope-blockreferences)', '<Plug>(iwe-picker-blockreferences)', { remap = true })
  vim.keymap.set('n', '<Plug>(iwe-telescope-backlinks)', '<Plug>(iwe-picker-backlinks)', { remap = true })
  vim.keymap.set('n', '<Plug>(iwe-telescope-headers)', '<Plug>(iwe-picker-headers)', { remap = true })
  vim.keymap.set('n', '<Plug>(iwe-telescope-grep)', '<Plug>(iwe-picker-grep)', { remap = true })

  -- Preview mappings
  create_plug_mapping('preview-squash', function()
    require('iwe.preview').generate_squash_preview()
  end, 'n', {
    silent = true,
    desc = 'Generate squash markdown preview'
  })

  create_plug_mapping('preview-export', function()
    require('iwe.preview').generate_export_preview()
  end, 'n', {
    silent = true,
    desc = 'Generate export graph preview'
  })

  create_plug_mapping('preview-export-headers', function()
    require('iwe.preview').generate_export_headers_preview()
  end, 'n', {
    silent = true,
    desc = 'Generate export graph with headers preview'
  })

  create_plug_mapping('preview-export-workspace', function()
    require('iwe.preview').generate_export_workspace_preview()
  end, 'n', {
    silent = true,
    desc = 'Generate workspace graph preview'
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

  create_plug_mapping('lsp-toggle-inlay-hints', function()
    require('iwe.lsp').toggle_inlay_hints()
  end, 'n', {
    silent = true,
    desc = 'Toggle inlay hints'
  })

  create_plug_mapping('lsp-go-to-definition', function()
    vim.lsp.buf.definition()
  end, 'n', {
    silent = true,
    desc = 'Go to definition'
  })

  -- Visual mode code action
  create_plug_mapping('lsp-link', function()
    vim.lsp.buf.code_action({apply = true, context = { only = {"custom.link"}}})
  end, 'v', {
    silent = true,
    desc = 'Create link from selection'
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
      vim.keymap.set('n', '<CR>', '<Plug>(iwe-lsp-go-to-definition)', map_opts)

      -- Insert mode mappings
      vim.keymap.set('i', '/d', '<Plug>(iwe-insert-date)', { buffer = buf })
      vim.keymap.set('i', '/w', '<Plug>(iwe-insert-week)', { buffer = buf })

      -- Visual mode mapping
      vim.keymap.set('v', '<CR>', '<Plug>(iwe-lsp-link)', { buffer = buf, silent = true })

      -- Picker keybindings (if enabled)
      -- Also check deprecated enable_telescope_keybindings for backward compatibility
      if config.get().mappings.enable_picker_keybindings then
        vim.keymap.set('n', 'gf', '<Plug>(iwe-picker-find-files)', { buffer = buf })
        vim.keymap.set('n', 'gs', '<Plug>(iwe-picker-paths)', { buffer = buf })
        vim.keymap.set('n', 'ga', '<Plug>(iwe-picker-roots)', { buffer = buf })
        vim.keymap.set('n', 'g/', '<Plug>(iwe-picker-grep)', { buffer = buf })
        vim.keymap.set('n', 'gb', '<Plug>(iwe-picker-blockreferences)', { buffer = buf })
        vim.keymap.set('n', 'gR', '<Plug>(iwe-picker-backlinks)', { buffer = buf })
        vim.keymap.set('n', 'go', '<Plug>(iwe-picker-headers)', { buffer = buf })
      end

      -- IWE-specific LSP keybindings (if enabled)
      if config.get().mappings.enable_lsp_keybindings then
        vim.keymap.set('n', opts.mappings.leader .. 'h', '<Plug>(iwe-lsp-rewrite-list-section)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'l', '<Plug>(iwe-lsp-rewrite-section-list)', { buffer = buf })
      end

      -- Preview keybindings (if enabled)
      if config.get().mappings.enable_preview_keybindings then
        vim.keymap.set('n', opts.mappings.leader .. 'ps', '<Plug>(iwe-preview-squash)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'pe', '<Plug>(iwe-preview-export)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'ph', '<Plug>(iwe-preview-export-headers)', { buffer = buf })
        vim.keymap.set('n', opts.mappings.leader .. 'pw', '<Plug>(iwe-preview-export-workspace)', { buffer = buf })
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
