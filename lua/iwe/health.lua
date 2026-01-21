---@class IWE.Health
local M = {}

local health = vim.health or require('health')

---Check if iwes LSP server is available
local function check_lsp_server()
  health.start('IWE LSP Server')

  if vim.fn.executable('iwes') == 1 then
    health.ok('iwes command found in PATH')

    -- Test if iwes can be used as LSP server by checking file type
    local iwes_path = vim.fn.exepath('iwes')
    if iwes_path and iwes_path ~= '' then
      health.info(string.format('iwes location: %s', iwes_path))

      -- Check if it's executable
      if vim.fn.getfperm(iwes_path):sub(3,3) == 'x' then
        health.ok('iwes is executable')
      else
        health.warn('iwes found but may not be executable')
      end
    else
      health.warn('Could not determine iwes location')
    end
  else
    health.error('iwes command not found in PATH', {
      'Install the iwes LSP server',
      'Make sure iwes is in your PATH',
      'Verify iwes is executable: chmod +x /path/to/iwes'
    })
  end
end

---Check IWE project structure
local function check_project_structure()
  health.start('IWE Project Structure')

  local found_iwe_marker = false

  -- Check for .iwe marker using vim.fs.root
  local iwe_root = vim.fs.root(0, {'.iwe'})
  if iwe_root then
    health.ok(string.format('.iwe marker found at %s/.iwe', iwe_root))
    found_iwe_marker = true
  else
    -- Also check current working directory
    local cwd_iwe = vim.fn.getcwd() .. '/.iwe'
    if vim.fn.isdirectory(cwd_iwe) == 1 then
      health.ok(string.format('.iwe marker found at %s', cwd_iwe))
      found_iwe_marker = true
    end
  end

  if not found_iwe_marker then
    health.warn('.iwe marker directory not found', {
      'Create a .iwe directory in your notes/project root',
      'This directory is required for LSP server activation'
    })
  end
end

---Check configuration paths
local function check_configuration()
  health.start('Configuration')

  local config = require('iwe.config').get()

  -- Check LSP configuration
  health.info(string.format('LSP command: %s', table.concat(config.lsp.cmd, ' ')))
  health.info(string.format('LSP name: %s', config.lsp.name))
  health.info(string.format('Auto format on save: %s', config.lsp.auto_format_on_save))
  health.info(string.format('Debounce text changes: %dms', config.lsp.debounce_text_changes))

  -- Check mapping configuration
  health.info(string.format('Markdown mappings enabled: %s', config.mappings.enable_markdown_mappings))
  health.info(string.format('Telescope keybindings enabled: %s', config.mappings.enable_telescope_keybindings))
  health.info(string.format('LSP keybindings enabled: %s', config.mappings.enable_lsp_keybindings))
  health.info(string.format('Preview keybindings enabled: %s', config.mappings.enable_preview_keybindings))
  health.info(string.format('Leader key: %s', config.mappings.leader))
  health.info(string.format('Local leader key: %s', config.mappings.localleader))

  -- Check telescope configuration
  health.info(string.format('Telescope enabled: %s', config.telescope.enabled))
  health.info(string.format('Telescope setup config: %s', config.telescope.setup_config))
  health.info(string.format('Telescope extensions: %s', table.concat(config.telescope.load_extensions, ', ')))

  -- Check preview configuration
  health.info(string.format('Preview output dir: %s', config.preview.output_dir))
  health.info(string.format('Preview temp dir: %s', config.preview.temp_dir))
  health.info(string.format('Preview auto open: %s', config.preview.auto_open))
end

---Check picker backends
local function check_picker_backends()
  health.start('Picker Backends')

  local picker = require('iwe.picker')
  local config = require('iwe.config').get()

  -- Show configured backend
  local backend_config = config.picker and config.picker.backend or "auto"
  if type(backend_config) == "function" then
    health.info('Configured backend: custom function')
  else
    health.info(string.format('Configured backend: %s', backend_config))
  end

  -- Check available backends
  local available = picker.list_backends()
  if #available > 0 then
    health.ok(string.format('Available backends: %s', table.concat(available, ", ")))
  else
    health.warn('No picker backends available', {
      'Install telescope.nvim, fzf-lua, snacks.nvim, or mini.pick',
      'vim.ui.select will be used as fallback for LSP-based pickers'
    })
  end

  -- Show active backend
  local active = picker.get_backend()
  if active then
    health.ok(string.format('Active backend: %s', active))
  else
    health.info('Active backend: vim.ui.select (fallback)')
  end

  -- Check individual backends
  local backends = {
    { name = "telescope", check = function() return pcall(require, 'telescope') end },
    { name = "fzf-lua", check = function() return pcall(require, 'fzf-lua') end },
    { name = "snacks", check = function()
      local ok, snacks = pcall(require, 'snacks')
      return ok and snacks.picker ~= nil
    end },
    { name = "mini.pick", check = function() return pcall(require, 'mini.pick') end },
  }

  for _, backend in ipairs(backends) do
    if backend.check() then
      health.ok(string.format('%s plugin detected', backend.name))
    else
      health.info(string.format('%s plugin not found (optional)', backend.name))
    end
  end

  -- Check Telescope extensions if telescope is available
  local has_telescope = pcall(require, 'telescope')
  if has_telescope and config.telescope then
    for _, ext in ipairs(config.telescope.load_extensions or {}) do
      local ok = pcall(require('telescope').load_extension, ext)
      if ok then
        health.ok(string.format('telescope extension "%s" available', ext))
      else
        health.info(string.format('telescope extension "%s" not found (optional)', ext))
      end
    end
  end
end

---Check dependencies
local function check_dependencies()
  health.start('Dependencies')

  -- Check for RenderMarkdown plugin
  local has_render_markdown = pcall(require, 'render-markdown')
  if has_render_markdown then
    health.ok('render-markdown plugin detected')
  else
    health.info('render-markdown plugin not found (optional)', {
      'Install render-markdown for enhanced markdown display'
    })
  end

  -- Check for Gitsigns plugin
  local has_gitsigns = pcall(require, 'gitsigns')
  if has_gitsigns then
    health.ok('gitsigns plugin detected')
  else
    health.info('gitsigns plugin not found (optional)', {
      'Install gitsigns for git integration features'
    })
  end
end

---Check preview functionality
local function check_preview()
  health.start('Preview Dependencies')

  -- Check for iwe CLI
  if vim.fn.executable('iwe') == 1 then
    health.ok('iwe CLI found in PATH')

    local iwe_path = vim.fn.exepath('iwe')
    if iwe_path and iwe_path ~= '' then
      health.info(string.format('iwe CLI location: %s', iwe_path))
    end
  else
    health.error('iwe CLI not found in PATH', {
      'Install the IWE CLI from https://github.com/iwe-org/iwe',
      'Make sure iwe is in your PATH',
      'Preview functionality requires the iwe CLI'
    })
  end

  -- Check for neato (Graphviz)
  if vim.fn.executable('neato') == 1 then
    health.ok('neato (Graphviz) found in PATH')

    local neato_path = vim.fn.exepath('neato')
    if neato_path and neato_path ~= '' then
      health.info(string.format('neato location: %s', neato_path))
    end
  else
    health.error('neato (Graphviz) not found in PATH', {
      'Install Graphviz package for your system',
      'macOS: brew install graphviz',
      'Ubuntu/Debian: sudo apt install graphviz',
      'Preview SVG generation requires neato'
    })
  end

  -- Check preview output directory
  local config = require('iwe.config').get()
  local output_dir = config.preview.output_dir

  if vim.fn.isdirectory(output_dir) == 1 then
    health.ok(string.format('Preview output directory exists: %s', output_dir))
  else
    -- Check if parent directory is writable for creation
    local parent_dir = vim.fn.fnamemodify(output_dir, ':h')
    if vim.fn.isdirectory(parent_dir) == 1 and vim.fn.filewritable(parent_dir) == 2 then
      health.ok(string.format('Preview output directory can be created: %s', output_dir))
    else
      health.warn(string.format('Cannot create preview output directory: %s', output_dir), {
        'Check that parent directory exists and is writable',
        'Update preview.output_dir configuration if needed'
      })
    end
  end

  -- Test preview functionality if available
  local preview = require('iwe.preview')
  if preview.is_available() then
    health.ok('Preview functionality available')

    local status = preview.get_status()
    if status.current_file_key then
      health.info(string.format('Current file key: %s', status.current_file_key))
    else
      health.info('No current file key (save current buffer to enable file-specific previews)')
    end
  else
    health.warn('Preview functionality not available', {
      'Ensure both iwe CLI and neato are installed and in PATH'
    })
  end
end

---Check current LSP status
local function check_lsp_status()
  health.start('LSP Status')

  local clients = vim.lsp.get_clients({ name = 'iwes' })
  if #clients > 0 then
    health.ok(string.format('IWE LSP server running (%d client%s)',
      #clients, #clients == 1 and '' or 's'))

    for i, client in ipairs(clients) do
      local buffers = {}
      for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
        table.insert(buffers, vim.api.nvim_buf_get_name(buf))
      end
      health.info(string.format('Client %d: %s', i, table.concat(buffers, ', ')))
    end
  else
    health.info('IWE LSP server not currently running')
  end
end

---Run all health checks
function M.check()
  check_lsp_server()
  check_project_structure()
  check_configuration()
  check_picker_backends()
  check_dependencies()
  check_preview()
  check_lsp_status()
end

return M

