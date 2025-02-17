local iwe = require('iwe')
local config = require('iwe.config')

describe('IWE Plugin', function()
  before_each(function()
    -- Reset config before each test
    config.options = {}
  end)

  describe('setup', function()
    it('should initialize with default configuration', function()
      iwe.setup()
      local opts = config.get()
      
      assert.are.equal(opts.lsp.cmd[1], 'iwes')
      assert.are.equal(opts.lsp.name, 'iwes')
      assert.are.equal(opts.mappings.enable_markdown_mappings, true)
      assert.are.equal(opts.mappings.enable_telescope_keybindings, false)
      assert.are.equal(opts.mappings.enable_lsp_keybindings, false)
    end)
    
    it('should merge user configuration', function()
      iwe.setup({
        mappings = {
          enable_telescope_keybindings = true
        }
      })
      local opts = config.get()
      
      assert.are.equal(opts.mappings.enable_telescope_keybindings, true)
      assert.are.equal(opts.mappings.enable_markdown_mappings, true) -- default preserved
    end)
  end)

  describe('project detection', function()
    it('should detect .iwe marker directory', function()
      -- Mock vim.fs.root for testing
      local original_root = vim.fs.root
      vim.fs.root = function(source, names)
        if names[1] == '.iwe' then
          return '/tmp/test-project'
        end
        return nil
      end
      
      local root = iwe.get_project_root()
      assert.are.equal(root, '/tmp/test-project')
      
      -- Restore original function
      vim.fs.root = original_root
    end)
  end)
end)