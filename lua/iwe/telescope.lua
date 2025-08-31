---@class IWE.Telescope
local M = {}

local _ = require('iwe.config')

---Check if Telescope is available
---@return boolean
function M.is_available()
  return pcall(require, 'telescope')
end

---Setup Telescope configuration
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

---Telescope pickers for IWE
local pickers = {}

---Find files with Telescope (equivalent to gf)
function pickers.find_files()
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').find_files({
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.7,
        width = 0.9,
        height = 0.9,
      },
    },
  })
end

---Dynamic workspace symbols - paths (equivalent to gs)
function pickers.paths()
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').lsp_dynamic_workspace_symbols({
    prompt_title = "IWE Paths",
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
  })
end

---Dynamic workspace symbols - namespace symbols as roots (equivalent to ga)
function pickers.roots()
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').lsp_dynamic_workspace_symbols({
    symbols = { "namespace" },
    prompt_title = "IWE Roots",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.7,
        width = 0.9,
        height = 0.9,
      },
    },
  })
end

---LSP references - block references (equivalent to gb)
function pickers.blockreferences()
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').lsp_references({
    prompt_title = "IWE Block references",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.7,
        width = 0.9,
        height = 0.9,
      },
    },
    include_declaration = false,
  })
end

---LSP references - backlinks (equivalent to gR)
function pickers.backlinks()
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').lsp_references({
    prompt_title = "IWE Backlinks",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.7,
        width = 0.9,
        height = 0.9,
      },
    },
    include_declaration = true,
  })
end

---LSP document symbols - headers (equivalent to go)
function pickers.headers()
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').lsp_document_symbols({
    prompt_title = "IWE Headers",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.7,
        width = 0.9,
        height = 0.9,
      },
    },
  })
end

---Live grep
function pickers.grep()
  if not M.is_available() then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').live_grep({
    prompt_title = "Live Grep",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.7,
        width = 0.9,
        height = 0.9,
      },
    },
  })
end


-- Export pickers
M.pickers = pickers

return M

