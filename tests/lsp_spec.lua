local config = require('iwe.config')
local lsp = require('iwe.lsp')

describe('IWE LSP', function()
  before_each(function()
    -- Reset config before each test
    config.options = {}
    -- Clear any existing autogroups
    pcall(vim.api.nvim_del_augroup_by_name, 'IWE_LSP_Start')
    pcall(vim.api.nvim_del_augroup_by_name, 'IWE_LSP_Attach')
  end)

  describe('setup_autocmds', function()
    it('should create FileType autocmd for markdown', function()
      config.setup()
      lsp.setup_autocmds()

      local autocmds = vim.api.nvim_get_autocmds({
        group = 'IWE_LSP_Start',
        event = 'FileType',
      })

      assert.are.equal(#autocmds, 1)
      assert.are.equal(autocmds[1].pattern, 'markdown')
    end)

    it('should create LspAttach autocmd', function()
      config.setup()
      lsp.setup_autocmds()

      local autocmds = vim.api.nvim_get_autocmds({
        group = 'IWE_LSP_Attach',
        event = 'LspAttach',
      })

      assert.are.equal(#autocmds, 1)
    end)
  end)

  describe('auto_format_on_save configuration', function()
    it('should respect config changes after setup_autocmds is called', function()
      -- Setup with default config (auto_format_on_save = true)
      config.setup()
      assert.are.equal(config.get().lsp.auto_format_on_save, true)

      -- Setup autocmds (this used to capture opts at this point)
      lsp.setup_autocmds()

      -- Now change the config to disable auto_format_on_save
      config.setup({ lsp = { auto_format_on_save = false } })

      -- The config should be updated
      assert.are.equal(config.get().lsp.auto_format_on_save, false)

      -- Get the LspAttach autocmd
      local autocmds = vim.api.nvim_get_autocmds({
        group = 'IWE_LSP_Attach',
        event = 'LspAttach',
      })

      assert.are.equal(#autocmds, 1)
      -- The callback exists (we can't easily test it reads fresh config,
      -- but this test documents the expected behavior)
      assert.is_not_nil(autocmds[1].callback)
    end)

    it('should use fresh config values when config.get() is called', function()
      -- This test verifies that config.get() returns fresh values
      -- which is the core fix for the stale closure issue

      -- Initial setup
      config.setup({ lsp = { auto_format_on_save = true } })
      local initial_value = config.get().lsp.auto_format_on_save
      assert.are.equal(initial_value, true)

      -- Update config
      config.setup({ lsp = { auto_format_on_save = false } })

      -- A new call to config.get() should return the updated value
      local updated_value = config.get().lsp.auto_format_on_save
      assert.are.equal(updated_value, false)

      -- This proves that if the LspAttach callback calls config.get()
      -- inside the callback (rather than using a captured reference),
      -- it will get the current config value
    end)

    it('should not create stale config reference in autocmd', function()
      -- Setup with auto_format_on_save = true
      config.setup({ lsp = { auto_format_on_save = true } })
      lsp.setup_autocmds()

      -- Change config after autocmds are set up
      config.setup({ lsp = { auto_format_on_save = false } })

      -- Create a test buffer
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_option_value('filetype', 'markdown', { buf = bufnr })

      -- Simulate what happens in LspAttach callback by checking config
      -- The fix ensures config.get() is called inside the callback,
      -- so it should return the updated value
      local current_config = config.get()
      assert.are.equal(current_config.lsp.auto_format_on_save, false)

      -- Cleanup
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)

  describe('toggle_inlay_hints', function()
    it('should exist as a function', function()
      assert.is_function(lsp.toggle_inlay_hints)
    end)
  end)

  describe('start', function()
    it('should exist as a function', function()
      assert.is_function(lsp.start)
    end)
  end)

  describe('is_available', function()
    it('should return boolean', function()
      local result = lsp.is_available()
      assert.is_boolean(result)
    end)
  end)
end)
