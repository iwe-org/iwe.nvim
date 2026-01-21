describe('IWE Commands', function()
  it('should have IWE command available', function()
    -- Check that the IWE command exists
    local commands = vim.api.nvim_get_commands({})
    assert.is_not_nil(commands['IWE'])
    assert.are.equal(commands['IWE'].nargs, '*')
  end)

  it('should validate command structure', function()
    local commands = vim.api.nvim_get_commands({})
    local iwe_cmd = commands['IWE']

    assert.is_not_nil(iwe_cmd)
    assert.are.equal(iwe_cmd.name, 'IWE')
    assert.is_true(iwe_cmd.complete ~= nil)
  end)
end)

describe('IWE Picker Commands', function()
  it('should have picker commands in completion', function()
    -- Test that command completion includes picker commands
    local picker_commands = {
      'find_files',
      'paths',
      'roots',
      'grep',
      'blockreferences',
      'backlinks',
      'headers',
    }

    -- Get completion for :IWE
    local completions = vim.fn.getcompletion('IWE ', 'cmdline')

    for _, cmd in ipairs(picker_commands) do
      local found = false
      for _, completion in ipairs(completions) do
        if completion == cmd then
          found = true
          break
        end
      end
      assert.is_true(found, 'Picker command should be in completions: ' .. cmd)
    end
  end)

  it('should still have deprecated telescope command in completion', function()
    local completions = vim.fn.getcompletion('IWE ', 'cmdline')

    local has_telescope = false
    for _, completion in ipairs(completions) do
      if completion == 'telescope' then
        has_telescope = true
        break
      end
    end
    assert.is_true(has_telescope, 'telescope command should still be available for backward compat')
  end)
end)

describe('IWE Plug Mappings', function()
  it('should have picker plug mappings', function()
    local picker_mappings = {
      '<Plug>(iwe-picker-find-files)',
      '<Plug>(iwe-picker-paths)',
      '<Plug>(iwe-picker-roots)',
      '<Plug>(iwe-picker-grep)',
      '<Plug>(iwe-picker-blockreferences)',
      '<Plug>(iwe-picker-backlinks)',
      '<Plug>(iwe-picker-headers)',
    }

    for _, mapping in ipairs(picker_mappings) do
      local map_info = vim.fn.maparg(mapping, 'n')
      assert.is_not_nil(map_info)
      assert.is_true(map_info ~= '', 'Mapping should exist: ' .. mapping)
    end
  end)

  it('should have backward-compat telescope plug mappings', function()
    local telescope_mappings = {
      '<Plug>(iwe-telescope-find-files)',
      '<Plug>(iwe-telescope-paths)',
      '<Plug>(iwe-telescope-roots)',
      '<Plug>(iwe-telescope-grep)',
      '<Plug>(iwe-telescope-blockreferences)',
      '<Plug>(iwe-telescope-backlinks)',
      '<Plug>(iwe-telescope-headers)',
    }

    for _, mapping in ipairs(telescope_mappings) do
      local map_info = vim.fn.maparg(mapping, 'n')
      assert.is_not_nil(map_info)
      assert.is_true(map_info ~= '', 'Backward-compat mapping should exist: ' .. mapping)
    end
  end)

  it('telescope mappings should remap to picker mappings', function()
    -- Check that telescope mappings point to picker mappings
    local map_info = vim.fn.maparg('<Plug>(iwe-telescope-find-files)', 'n')
    assert.is_true(string.find(map_info, 'picker') ~= nil or string.find(map_info, 'Plug') ~= nil,
      'Telescope mapping should remap to picker')
  end)
end)
