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

  local config = require('iwe.config').get()
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
  health.info(string.format('Leader key: %s', config.mappings.leader))
  health.info(string.format('Local leader key: %s', config.mappings.localleader))

  -- Check telescope configuration
  health.info(string.format('Telescope enabled: %s', config.telescope.enabled))
  health.info(string.format('Telescope setup config: %s', config.telescope.setup_config))
  health.info(string.format('Telescope extensions: %s', table.concat(config.telescope.load_extensions, ', ')))
end

---Check dependencies
local function check_dependencies()
  health.start('Dependencies')

  -- Check for Telescope (now a main dependency)
  local telescope = require('iwe.telescope')
  if telescope.is_available() then
    health.ok('telescope.nvim plugin detected')

    -- Check for Telescope extensions
    local config = require('iwe.config').get()
    for _, ext in ipairs(config.telescope.load_extensions) do
      local ok = pcall(require('telescope').load_extension, ext)
      if ok then
        health.ok(string.format('telescope extension "%s" available', ext))
      else
        health.info(string.format('telescope extension "%s" not found (optional)', ext))
      end
    end
  else
    health.error('telescope.nvim plugin not found', {
      'Install nvim-telescope/telescope.nvim',
      'Telescope is required for IWE fuzzy finding functionality'
    })
  end

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
  check_dependencies()
  check_lsp_status()
end

return M
