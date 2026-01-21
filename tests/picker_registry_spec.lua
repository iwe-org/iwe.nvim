describe('IWE Picker Registry', function()
  local registry

  before_each(function()
    -- Clear cached modules
    package.loaded['iwe.picker.registry'] = nil
    package.loaded['iwe.picker.adapters.telescope'] = nil
    package.loaded['iwe.picker.adapters.fzf_lua'] = nil
    package.loaded['iwe.picker.adapters.snacks'] = nil
    package.loaded['iwe.picker.adapters.mini'] = nil
    package.loaded['iwe.picker.adapters.vim_ui'] = nil

    registry = require('iwe.picker.registry')
  end)

  describe('structure', function()
    it('should have priority list', function()
      assert.is_table(registry.priority)
      assert.is_true(#registry.priority > 0)
    end)

    it('should have correct priority order', function()
      assert.are.equal(registry.priority[1], 'telescope')
      assert.are.equal(registry.priority[2], 'fzf_lua')
      assert.are.equal(registry.priority[3], 'snacks')
      assert.are.equal(registry.priority[4], 'mini')
      assert.are.equal(registry.priority[5], 'vim_ui')
    end)

    it('should have adapters table', function()
      assert.is_table(registry.adapters)
    end)
  end)

  describe('adapter registration', function()
    it('should register adapters', function()
      local mock_adapter = {
        name = 'mock',
        is_available = function() return true end,
        find_files = function() end,
        grep = function() end,
        lsp_workspace_symbols = function() end,
        lsp_document_symbols = function() end,
        lsp_references = function() end,
      }

      registry.register('mock', mock_adapter)
      assert.are.equal(registry.adapters['mock'], mock_adapter)
    end)

    it('should retrieve registered adapters', function()
      local mock_adapter = {
        name = 'mock2',
        is_available = function() return true end,
      }

      registry.register('mock2', mock_adapter)
      local retrieved = registry.get('mock2')
      assert.are.equal(retrieved, mock_adapter)
    end)

    it('should return nil for unregistered adapters', function()
      local result = registry.get('nonexistent')
      assert.is_nil(result)
    end)
  end)

  describe('adapter loading', function()
    it('should load all adapters', function()
      registry.load_adapters()

      -- vim_ui should always be loaded
      assert.is_not_nil(registry.adapters['vim_ui'])
    end)

    it('should have vim_ui adapter with required methods', function()
      registry.load_adapters()

      local vim_ui = registry.adapters['vim_ui']
      assert.is_not_nil(vim_ui)
      assert.are.equal(vim_ui.name, 'vim_ui')
      assert.is_function(vim_ui.is_available)
      assert.is_function(vim_ui.find_files)
      assert.is_function(vim_ui.grep)
      assert.is_function(vim_ui.lsp_workspace_symbols)
      assert.is_function(vim_ui.lsp_document_symbols)
      assert.is_function(vim_ui.lsp_references)
    end)
  end)

  describe('availability checking', function()
    it('should check adapter availability', function()
      registry.load_adapters()

      -- vim_ui should always be available
      local is_available = registry.is_available('vim_ui')
      assert.is_true(is_available)
    end)

    it('should return false for unavailable adapters', function()
      local is_available = registry.is_available('nonexistent')
      assert.is_false(is_available)
    end)
  end)

  describe('detection', function()
    it('should detect available backend', function()
      registry.load_adapters()

      local detected = registry.detect()
      assert.is_not_nil(detected)
    end)

    it('should return at least vim_ui', function()
      registry.load_adapters()

      local available = registry.list_available()
      local has_vim_ui = false
      for _, name in ipairs(available) do
        if name == 'vim_ui' then
          has_vim_ui = true
          break
        end
      end
      assert.is_true(has_vim_ui)
    end)

    it('should list available backends in priority order', function()
      registry.load_adapters()

      local available = registry.list_available()
      assert.is_table(available)
      assert.is_true(#available >= 1)

      -- Verify order matches priority
      local priority_map = {}
      for i, name in ipairs(registry.priority) do
        priority_map[name] = i
      end

      for i = 1, #available - 1 do
        local current_priority = priority_map[available[i]]
        local next_priority = priority_map[available[i + 1]]
        assert.is_true(current_priority < next_priority,
          string.format('%s should come before %s', available[i], available[i + 1]))
      end
    end)
  end)
end)
