-- IWE Plugin Entry Point
-- Minimal entry point that defers loading until needed

-- Prevent loading if plugin is disabled
if vim.g.loaded_iwe or vim.g.disable_iwe then
  return
end

vim.g.loaded_iwe = 1

-- Auto-initialize with defaults unless the user calls require('iwe').setup()
-- themselves. This must live here: plugin/ files are the only code Neovim
-- sources automatically, while modules under lua/ only run when required.
local function auto_init()
  if next(require('iwe.config').get()) == nil then
    require('iwe').setup({})
  end
end

if vim.v.vim_did_enter == 1 then
  auto_init()
else
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = auto_init,
    once = true,
    group = vim.api.nvim_create_augroup('IWE_AutoInit', { clear = true }),
    desc = 'Auto-initialize IWE plugin with defaults'
  })
end
