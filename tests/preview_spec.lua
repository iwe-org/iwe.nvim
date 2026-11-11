local preview = require('iwe.preview')

-- Name the current buffer without running filetype plugins, which need parsers
-- the test runtime does not have
local function open_named(path)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, path)
  vim.api.nvim_set_current_buf(buf)
end

describe('preview', function()
  local root

  before_each(function()
    root = vim.fn.tempname()
    vim.fn.mkdir(root .. '/.iwe', 'p')
    vim.fn.mkdir(root .. '/plans', 'p')
  end)

  after_each(function()
    vim.cmd('silent! %bwipeout!')
    vim.fn.delete(root, 'rf')
  end)

  it('keys a nested document by its path from the project root', function()
    open_named(root .. '/plans/example-plan.md')

    assert.are.equal('plans/example-plan', preview.get_status().current_file_key)
  end)

  it('has no key for a file outside an IWE project', function()
    local outside = vim.fn.tempname()
    vim.fn.mkdir(outside, 'p')
    open_named(outside .. '/note.md')

    assert.is_nil(preview.get_status().current_file_key)

    vim.fn.delete(outside, 'rf')
  end)
end)
