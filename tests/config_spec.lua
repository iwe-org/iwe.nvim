local config = require('iwe.config')

describe('IWE Configuration', function()
  before_each(function()
    -- Reset config before each test
    config.options = {}
  end)

  it('should have correct default values', function()
    config.setup()
    local opts = config.get()

    assert.are.equal(opts.lsp.name, 'iwes')
    assert.are.equal(opts.lsp.debounce_text_changes, 500)
    assert.are.equal(opts.lsp.auto_format_on_save, true)
    assert.are.equal(opts.mappings.enable_markdown_mappings, true)
    assert.are.equal(opts.mappings.enable_picker_keybindings, false)
    assert.are.equal(opts.mappings.enable_lsp_keybindings, false)
    assert.are.equal(opts.picker.backend, 'auto')
    assert.are.equal(opts.picker.fallback_notify, true)
    assert.are.equal(opts.telescope.enabled, true)
  end)

  it('should merge user configuration correctly', function()
    config.setup({
      lsp = {
        debounce_text_changes = 1000,
      },
      mappings = {
        enable_telescope_keybindings = true,
      }
    })
    local opts = config.get()

    -- User config should override
    assert.are.equal(opts.lsp.debounce_text_changes, 1000)
    assert.are.equal(opts.mappings.enable_telescope_keybindings, true)

    -- Defaults should be preserved
    assert.are.equal(opts.lsp.name, 'iwes')
    assert.are.equal(opts.mappings.enable_markdown_mappings, true)
  end)

  it('should validate configuration', function()
    -- This should not throw an error
    config.setup({
      lsp = {
        cmd = { 'valid-command' },
        name = 'valid-name',
        debounce_text_changes = 100,
      }
    })

    local opts = config.get()
    assert.are.equal(opts.lsp.name, 'valid-name')
  end)

  it('should handle get_value function', function()
    config.setup()

    local lsp_name = config.get_value('lsp.name')
    assert.are.equal(lsp_name, 'iwes')

    local enable_markdown = config.get_value('mappings.enable_markdown_mappings')
    assert.are.equal(enable_markdown, true)

    local nonexistent = config.get_value('nonexistent.path')
    assert.is_nil(nonexistent)
  end)
end)

describe('IWE Picker Configuration', function()
  before_each(function()
    config.options = {}
  end)

  it('should accept valid backend strings', function()
    local valid_backends = { 'auto', 'telescope', 'fzf_lua', 'snacks', 'mini', 'vim_ui' }

    for _, backend in ipairs(valid_backends) do
      config.options = {}
      config.setup({
        picker = {
          backend = backend
        }
      })
      local opts = config.get()
      assert.are.equal(opts.picker.backend, backend)
    end
  end)

  it('should accept function as backend', function()
    local custom_fn = function() end
    config.setup({
      picker = {
        backend = custom_fn
      }
    })
    local opts = config.get()
    assert.are.equal(opts.picker.backend, custom_fn)
  end)

  it('should accept fallback_notify boolean', function()
    config.setup({
      picker = {
        fallback_notify = false
      }
    })
    local opts = config.get()
    assert.are.equal(opts.picker.fallback_notify, false)
  end)

  it('should handle deprecated enable_telescope_keybindings', function()
    config.setup({
      mappings = {
        enable_telescope_keybindings = true
      }
    })
    local opts = config.get()
    -- Should migrate to enable_picker_keybindings
    assert.are.equal(opts.mappings.enable_picker_keybindings, true)
  end)

  it('should prefer enable_picker_keybindings over deprecated option', function()
    config.setup({
      mappings = {
        enable_picker_keybindings = true,
        enable_telescope_keybindings = false
      }
    })
    local opts = config.get()
    assert.are.equal(opts.mappings.enable_picker_keybindings, true)
  end)

  it('should get picker backend via get_value', function()
    config.setup({
      picker = {
        backend = 'telescope'
      }
    })

    local backend = config.get_value('picker.backend')
    assert.are.equal(backend, 'telescope')
  end)
end)
