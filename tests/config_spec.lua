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
    assert.are.equal(opts.mappings.enable_telescope_keybindings, false)
    assert.are.equal(opts.mappings.enable_lsp_keybindings, false)
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
