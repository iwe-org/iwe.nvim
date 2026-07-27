local config = require('iwe.config')

describe('plugin entry point', function()
  local plugin_file = vim.api.nvim_get_runtime_file('plugin/iwe.lua', false)[1]

  local saved_options

  -- The plugin initializes immediately when sourced after startup, but the
  -- test harness runs before VimEnter, so the entry point registers a
  -- VimEnter autocmd instead; fire it to complete initialization
  local function fire_pending_auto_init()
    local ok, pending = pcall(vim.api.nvim_get_autocmds, {
      group = 'IWE_AutoInit',
      event = 'VimEnter',
    })
    if ok and #pending > 0 then
      vim.api.nvim_exec_autocmds('VimEnter', { group = 'IWE_AutoInit' })
    end
  end

  before_each(function()
    saved_options = config.options
    vim.g.loaded_iwe = nil
  end)

  after_each(function()
    config.options = saved_options
    vim.g.loaded_iwe = 1
    pcall(vim.api.nvim_del_augroup_by_name, 'IWE_AutoInit')
  end)

  it('should be discoverable on the runtimepath', function()
    assert.is_not_nil(plugin_file)
  end)

  it('should auto-initialize without an explicit setup() call', function()
    config.options = {}

    vim.cmd('source ' .. vim.fn.fnameescape(plugin_file))
    fire_pending_auto_init()

    assert.is_true(next(config.get()) ~= nil)
  end)

  it('should not override an existing configuration', function()
    config.options = {}
    require('iwe').setup({ lsp = { name = 'custom-iwes' } })

    vim.cmd('source ' .. vim.fn.fnameescape(plugin_file))
    fire_pending_auto_init()

    assert.are.equal('custom-iwes', config.get().lsp.name)
  end)

  it('should not load when disabled', function()
    config.options = {}
    vim.g.disable_iwe = true

    vim.cmd('source ' .. vim.fn.fnameescape(plugin_file))
    fire_pending_auto_init()

    assert.is_true(next(config.get()) == nil)
    vim.g.disable_iwe = nil
  end)
end)
