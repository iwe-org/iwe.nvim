---@class IWE.Telescope
---Backward compatibility wrapper for telescope integration.
---The picker functionality has been moved to lua/iwe/picker/.
---This module is kept for backward compatibility and telescope-specific setup.
local M = {}

local _ = require('iwe.config')

---Check if Telescope is available
---@return boolean
function M.is_available()
  return pcall(require, 'telescope')
end

---Setup Telescope configuration
---This function configures telescope-specific settings like layout and extensions.
---The picker functionality is now handled by the picker module.
function M.setup()
  if not M.is_available() then
    vim.notify("Telescope not found - IWE Telescope integration disabled", vim.log.levels.WARN)
    return
  end

  local telescope = require('telescope')
  local actions = require('telescope.actions')

  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ["<esc>"] = actions.close
        },
      },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({
          winblend = 30,
          border = false,
          previewer = false,
          prompt_prefix = "  ",
          layout_strategy = "cursor",
          layout_config = {
            width = 35,
            height = 7,
          },
        })
      }
    },
    pickers = {
      tags = {},
      lsp_references = {
        show_line = false,
        trim_text = false,
        include_declaration = true,
        include_current_line = true,
        theme = "dropdown",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            prompt_height = 1,
            results_height = 10,
            preview_width = 0.7,
            width = 0.9,
            height = 0.9,
          },
        },
      },
      git_files = {
        fname_width = 0,
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.7,
            width = 0.9,
            height = 0.9,
          },
        },
      },
      find_files = {
        fname_width = 0,
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.7,
            width = 0.9,
            height = 0.9,
          },
        },
      },
      lsp_document_symbols = {
        fname_width = 0,
        symbol_width = 100,
        symbol_type_width = 0,
        symbol_line = false,
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.7,
            width = 0.9,
            height = 0.9,
          },
        },
      },
      lsp_workspace_symbols = {
        fname_width = 0,
        symbol_width = 100,
        symbol_type_width = 0,
        symbol_line = false,
        layout_config = {
          horizontal = {
            preview_width = 0.5,
            width = 0.9,
            height = 0.9,
          },
        },
      },
      lsp_dynamic_workspace_symbols = {
        fname_width = 0,
        symbol_width = 100,
        symbol_type_width = 0,
        symbol_line = false,
        layout_config = {
          horizontal = {
            preview_width = 0.5,
            width = 0.9,
            height = 0.9,
          },
        },
      }
    }
  })

  -- Load extensions if available
  local extensions = { "ui-select", "emoji" }
  for _, extension in ipairs(extensions) do
    local ok = pcall(telescope.load_extension, extension)
    if not ok then
      vim.notify(string.format("Telescope extension '%s' not found", extension), vim.log.levels.DEBUG)
    end
  end
end

---@deprecated Use require('iwe.picker') instead
---Backward compatibility: pickers table that delegates to picker module
M.pickers = setmetatable({}, {
  __index = function(_, key)
    local picker = require('iwe.picker')
    local mapping = {
      find_files = picker.find_files,
      paths = picker.paths,
      roots = picker.roots,
      grep = picker.grep,
      blockreferences = picker.blockreferences,
      backlinks = picker.backlinks,
      headers = picker.headers,
    }
    if mapping[key] then
      return mapping[key]
    end
    return function()
      vim.notify(string.format("Unknown picker: %s", key), vim.log.levels.ERROR)
    end
  end
})

return M
