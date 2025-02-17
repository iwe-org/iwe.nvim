-- IWE Plugin Entry Point
-- Minimal entry point that defers loading until needed

-- Prevent loading if plugin is disabled
if vim.g.loaded_iwe or vim.g.disable_iwe then
  return
end

vim.g.loaded_iwe = 1

-- The main plugin logic is handled by lua/iwe/init.lua
-- This allows for proper lazy loading and modular architecture