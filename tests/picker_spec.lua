local config = require('iwe.config')

describe('IWE Picker', function()
  local picker

  before_each(function()
    -- Reset config before each test
    config.options = {}
    config.setup()

    -- Clear cached modules to ensure fresh state
    package.loaded['iwe.picker'] = nil
    package.loaded['iwe.picker.registry'] = nil

    picker = require('iwe.picker')
  end)

  describe('API', function()
    it('should expose all required functions', function()
      assert.is_function(picker.find_files)
      assert.is_function(picker.grep)
      assert.is_function(picker.paths)
      assert.is_function(picker.roots)
      assert.is_function(picker.headers)
      assert.is_function(picker.blockreferences)
      assert.is_function(picker.backlinks)
      assert.is_function(picker.is_available)
      assert.is_function(picker.get_backend)
      assert.is_function(picker.list_backends)
    end)

    it('should return boolean from is_available', function()
      local result = picker.is_available()
      assert.is_boolean(result)
    end)

    it('should return string or nil from get_backend', function()
      local result = picker.get_backend()
      assert.is_true(result == nil or type(result) == 'string')
    end)

    it('should return table from list_backends', function()
      local result = picker.list_backends()
      assert.is_table(result)
    end)
  end)

  describe('backend detection', function()
    it('should include vim_ui in available backends', function()
      local backends = picker.list_backends()
      local has_vim_ui = false
      for _, backend in ipairs(backends) do
        if backend == 'vim_ui' then
          has_vim_ui = true
          break
        end
      end
      assert.is_true(has_vim_ui, 'vim_ui should always be available')
    end)

    it('should detect telescope when available', function()
      local has_telescope = pcall(require, 'telescope')
      local backends = picker.list_backends()

      local telescope_in_list = false
      for _, backend in ipairs(backends) do
        if backend == 'telescope' then
          telescope_in_list = true
          break
        end
      end

      assert.are.equal(has_telescope, telescope_in_list)
    end)
  end)

  describe('configuration', function()
    it('should respect backend = "auto" config', function()
      config.setup({
        picker = {
          backend = 'auto'
        }
      })

      -- Reload picker with new config
      package.loaded['iwe.picker'] = nil
      picker = require('iwe.picker')

      -- Should return some backend (at least vim_ui)
      local backend = picker.get_backend()
      assert.is_not_nil(backend)
    end)

    it('should respect backend = "vim_ui" config', function()
      config.setup({
        picker = {
          backend = 'vim_ui'
        }
      })

      -- Reload picker with new config
      package.loaded['iwe.picker'] = nil
      picker = require('iwe.picker')

      local backend = picker.get_backend()
      assert.are.equal(backend, 'vim_ui')
    end)

    it('should handle custom function backend', function()
      config.setup({
        picker = {
          backend = function(_action, _opts)
            -- Custom backend function
          end
        }
      })

      -- Reload picker with new config
      package.loaded['iwe.picker'] = nil
      picker = require('iwe.picker')

      local backend = picker.get_backend()
      assert.are.equal(backend, 'custom')
    end)
  end)
end)

describe('IWE Picker backward compatibility', function()
  before_each(function()
    config.options = {}
    config.setup()
  end)

  it('should work via telescope.pickers proxy', function()
    local telescope = require('iwe.telescope')

    assert.is_not_nil(telescope.pickers)
    assert.is_function(telescope.pickers.find_files)
    assert.is_function(telescope.pickers.paths)
    assert.is_function(telescope.pickers.roots)
    assert.is_function(telescope.pickers.grep)
    assert.is_function(telescope.pickers.blockreferences)
    assert.is_function(telescope.pickers.backlinks)
    assert.is_function(telescope.pickers.headers)
  end)

  it('should have is_available function on telescope module', function()
    local telescope = require('iwe.telescope')
    assert.is_function(telescope.is_available)
  end)
end)
