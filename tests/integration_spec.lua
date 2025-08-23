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
