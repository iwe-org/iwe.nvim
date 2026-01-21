describe('IWE Picker Adapters', function()
  describe('vim_ui adapter', function()
    local vim_ui

    before_each(function()
      package.loaded['iwe.picker.adapters.vim_ui'] = nil
      vim_ui = require('iwe.picker.adapters.vim_ui')
    end)

    it('should have correct name', function()
      assert.are.equal(vim_ui.name, 'vim_ui')
    end)

    it('should always be available', function()
      assert.is_true(vim_ui.is_available())
    end)

    it('should have all required methods', function()
      assert.is_function(vim_ui.find_files)
      assert.is_function(vim_ui.grep)
      assert.is_function(vim_ui.lsp_workspace_symbols)
      assert.is_function(vim_ui.lsp_document_symbols)
      assert.is_function(vim_ui.lsp_references)
    end)

    it('should not error when calling find_files', function()
      -- find_files just shows a notification, shouldn't error
      assert.has_no.errors(function()
        vim_ui.find_files()
      end)
    end)

    it('should not error when calling grep', function()
      -- grep just shows a notification, shouldn't error
      assert.has_no.errors(function()
        vim_ui.grep()
      end)
    end)
  end)

  describe('telescope adapter', function()
    local telescope_adapter

    before_each(function()
      package.loaded['iwe.picker.adapters.telescope'] = nil
      telescope_adapter = require('iwe.picker.adapters.telescope')
    end)

    it('should have correct name', function()
      assert.are.equal(telescope_adapter.name, 'telescope')
    end)

    it('should have is_available function', function()
      assert.is_function(telescope_adapter.is_available)
    end)

    it('should return boolean from is_available', function()
      local result = telescope_adapter.is_available()
      assert.is_boolean(result)
    end)

    it('should have all required methods', function()
      assert.is_function(telescope_adapter.find_files)
      assert.is_function(telescope_adapter.grep)
      assert.is_function(telescope_adapter.lsp_workspace_symbols)
      assert.is_function(telescope_adapter.lsp_document_symbols)
      assert.is_function(telescope_adapter.lsp_references)
    end)
  end)

  describe('fzf_lua adapter', function()
    local fzf_lua_adapter

    before_each(function()
      package.loaded['iwe.picker.adapters.fzf_lua'] = nil
      fzf_lua_adapter = require('iwe.picker.adapters.fzf_lua')
    end)

    it('should have correct name', function()
      assert.are.equal(fzf_lua_adapter.name, 'fzf_lua')
    end)

    it('should have is_available function', function()
      assert.is_function(fzf_lua_adapter.is_available)
    end)

    it('should return boolean from is_available', function()
      local result = fzf_lua_adapter.is_available()
      assert.is_boolean(result)
    end)

    it('should have all required methods', function()
      assert.is_function(fzf_lua_adapter.find_files)
      assert.is_function(fzf_lua_adapter.grep)
      assert.is_function(fzf_lua_adapter.lsp_workspace_symbols)
      assert.is_function(fzf_lua_adapter.lsp_document_symbols)
      assert.is_function(fzf_lua_adapter.lsp_references)
    end)
  end)

  describe('snacks adapter', function()
    local snacks_adapter

    before_each(function()
      package.loaded['iwe.picker.adapters.snacks'] = nil
      snacks_adapter = require('iwe.picker.adapters.snacks')
    end)

    it('should have correct name', function()
      assert.are.equal(snacks_adapter.name, 'snacks')
    end)

    it('should have is_available function', function()
      assert.is_function(snacks_adapter.is_available)
    end)

    it('should return boolean from is_available', function()
      local result = snacks_adapter.is_available()
      assert.is_boolean(result)
    end)

    it('should have all required methods', function()
      assert.is_function(snacks_adapter.find_files)
      assert.is_function(snacks_adapter.grep)
      assert.is_function(snacks_adapter.lsp_workspace_symbols)
      assert.is_function(snacks_adapter.lsp_document_symbols)
      assert.is_function(snacks_adapter.lsp_references)
    end)
  end)

  describe('mini adapter', function()
    local mini_adapter

    before_each(function()
      package.loaded['iwe.picker.adapters.mini'] = nil
      mini_adapter = require('iwe.picker.adapters.mini')
    end)

    it('should have correct name', function()
      assert.are.equal(mini_adapter.name, 'mini')
    end)

    it('should have is_available function', function()
      assert.is_function(mini_adapter.is_available)
    end)

    it('should return boolean from is_available', function()
      local result = mini_adapter.is_available()
      assert.is_boolean(result)
    end)

    it('should have all required methods', function()
      assert.is_function(mini_adapter.find_files)
      assert.is_function(mini_adapter.grep)
      assert.is_function(mini_adapter.lsp_workspace_symbols)
      assert.is_function(mini_adapter.lsp_document_symbols)
      assert.is_function(mini_adapter.lsp_references)
    end)
  end)
end)

describe('Adapter interface consistency', function()
  local adapters = {}

  before_each(function()
    -- Clear all cached adapters
    package.loaded['iwe.picker.adapters.telescope'] = nil
    package.loaded['iwe.picker.adapters.fzf_lua'] = nil
    package.loaded['iwe.picker.adapters.snacks'] = nil
    package.loaded['iwe.picker.adapters.mini'] = nil
    package.loaded['iwe.picker.adapters.vim_ui'] = nil

    adapters = {
      require('iwe.picker.adapters.telescope'),
      require('iwe.picker.adapters.fzf_lua'),
      require('iwe.picker.adapters.snacks'),
      require('iwe.picker.adapters.mini'),
      require('iwe.picker.adapters.vim_ui'),
    }
  end)

  it('all adapters should have name property', function()
    for _, adapter in ipairs(adapters) do
      assert.is_string(adapter.name, 'Adapter should have name property')
    end
  end)

  it('all adapters should have unique names', function()
    local names = {}
    for _, adapter in ipairs(adapters) do
      assert.is_nil(names[adapter.name], 'Adapter name should be unique: ' .. adapter.name)
      names[adapter.name] = true
    end
  end)

  it('all adapters should implement the same interface', function()
    local required_methods = {
      'is_available',
      'find_files',
      'grep',
      'lsp_workspace_symbols',
      'lsp_document_symbols',
      'lsp_references',
    }

    for _, adapter in ipairs(adapters) do
      for _, method in ipairs(required_methods) do
        assert.is_function(adapter[method],
          string.format('Adapter %s should have method %s', adapter.name, method))
      end
    end
  end)
end)
