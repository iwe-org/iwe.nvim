# IWE Neovim Plugin

**About IWE**: This plugin integrates with the [IWE](https://github.com/iwe-org/iwe) - an LSP/CLI designed for markdown-based knowledge management and note-taking workflows.

You can learn more at [IWE.md](https://iwe.md)

## Features

- **🏗️ Project Initialization**: Create IWE projects with `:IWE init`
- **🔍 LSP Integration**: Automatically starts `iwes` LSP server for `.iwe` projects
- **🔭 Multi-Backend Picker**: Supports Telescope, fzf-lua, Snacks, mini.pick with vim.ui.select fallback
- **📝 Markdown Enhancements**: Writing-focused features for markdown editing
- **⚙️ Modern Architecture**: Type-safe, well-documented, with health checks

## Supported Picker Backends

The plugin supports multiple fuzzy finder backends (in priority order):

| Backend | Plugin | Notes |
|---------|--------|-------|
| Telescope | [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Full-featured, best LSP integration |
| fzf-lua | [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua) | Fast, fzf-based |
| Snacks | [folke/snacks.nvim](https://github.com/folke/snacks.nvim) | Modern, good capabilities |
| mini.pick | [echasnovski/mini.pick](https://github.com/echasnovski/mini.pick) | Lightweight |
| vim.ui.select | Built-in | Fallback for LSP-based pickers |

The plugin auto-detects the best available backend, or you can configure a specific one.

## Getting Started

### 1. Install the Plugin

Add to your Neovim configuration (using lazy.nvim):

```lua
{
  'iwe-org/iwe.nvim',
  dependencies = {
    -- At least one picker recommended (any of these):
    'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua',
    -- 'folke/snacks.nvim',
    -- 'echasnovski/mini.pick',
  },
  config = function()
    require('iwe').setup({
      -- All options are optional with sensible defaults
    })
  end
}
```

### 2. Verify Installation

After installing the plugin, run the health check to ensure everything is working:

```vim
:checkhealth iwe
```

This will verify:
- `iwes` LSP server is available in PATH ([install instructions](https://github.com/iwe-org/iwe))
- Picker backend availability
- Plugin configuration is valid

### 3. Initialize Your First IWE Directory

Navigate to your notes directory and run:

```vim
:IWE init
```

This creates a `.iwe` marker directory that:
- Identifies this directory as an IWE project root
- Enables LSP server integration
- Makes the project discoverable by the picker

### 4. Start Writing

Open any `.md` file in your IWE project and enjoy:
- Automatic LSP server integration
- Enhanced markdown editing features
- Seamless project-wide file navigation

## Commands

| Command | Description |
|---------|-------------|
| `:IWE init` | Initialize IWE project in current directory |
| `:IWE find_files` | Find files in project |
| `:IWE paths` | Workspace symbols (paths) |
| `:IWE roots` | Namespace symbols (roots) |
| `:IWE grep` | Live grep search |
| `:IWE blockreferences` | LSP references (no declaration) |
| `:IWE backlinks` | LSP references (with declaration) |
| `:IWE headers` | Document symbols (headers) |
| `:IWE lsp start/stop/restart/status/toggle_inlay_hints` | Control LSP server |
| `:IWE preview squash/export/export-headers/export-workspace` | Generate previews |
| `:IWE info` | Show plugin status and configuration |

## Preview Integration

The plugin provides preview generation using the IWE CLI:

- **`:IWE preview squash`** - Generate squashed markdown preview (combines content with depth 3)
- **`:IWE preview export`** - Generate basic DOT graph as SVG (depth 2)
- **`:IWE preview export-headers`** - Generate DOT graph with headers as SVG (depth 2, includes headers)
- **`:IWE preview export-workspace`** - Generate full workspace graph as SVG (depth 1, all files)

## Configuration

The plugin works out of the box, but can be customized:

```lua
require('iwe').setup({
  lsp = {
    cmd = { "iwes" },
    auto_format_on_save = true,
    enable_inlay_hints = true,
    debounce_text_changes = 500
  },
  mappings = {
    enable_markdown_mappings = true,  -- Core markdown editing keybindings
    enable_picker_keybindings = false, -- Set to true to enable gf, gs, ga, g/, gb, gR, go
    enable_lsp_keybindings = false,   -- Set to true to enable IWE-specific LSP keybindings
    enable_preview_keybindings = false, -- Set to true to enable preview keybindings
    leader = "<leader>",
    localleader = "<localleader>"
  },
  picker = {
    backend = "auto",  -- "auto", "telescope", "fzf_lua", "snacks", "mini", "vim_ui"
    fallback_notify = true
  },
  telescope = {
    enabled = true,
    setup_config = true,
    load_extensions = { "ui-select", "emoji" }
  },
  preview = {
    output_dir = "~/tmp/preview",
    temp_dir = "/tmp",
    auto_open = false
  }
})
```

## Default Key Mappings

### Markdown Editing (when `enable_markdown_mappings = true`)

In markdown files:

| Key | Action | Mode |
|-----|--------|------|
| `-` | Format current line as checklist item | Normal |
| `<C-n>` | Navigate to next link | Normal |
| `<C-p>` | Navigate to previous link | Normal |
| `<CR>` | Go to definition | Normal |
| `/d` | Insert current date | Insert |
| `/w` | Insert current week | Insert |
| `<CR>` | Create link from selection | Visual |

### Picker Navigation (when `enable_picker_keybindings = true`)

In markdown files:

| Key | Action | Command Equivalent |
|-----|--------|-------------------|
| `gf` | Find files | `:IWE find_files` |
| `gs` | Workspace symbols (paths) | `:IWE paths` |
| `ga` | Namespace symbols (roots) | `:IWE roots` |
| `g/` | Live grep search | `:IWE grep` |
| `gb` | Block references | `:IWE blockreferences` |
| `gR` | Backlinks | `:IWE backlinks` |
| `go` | Document symbols (headers) | `:IWE headers` |

### IWE LSP Keybindings (when `enable_lsp_keybindings = true`)

IWE-specific refactoring actions in markdown files:

| Key | Action |
|-----|--------|
| `<leader>h` | Rewrite list section (refactor) |
| `<leader>l` | Rewrite section list (refactor) |

### Default Neovim LSP Keybindings

Standard LSP actions are available when the LSP server is active:

| Key | Action |
|-----|--------|
| `gD` | Go to declaration |
| `gd` | Go to definition |
| `gi` | Go to implementation |
| `gr` | Show references |
| `K` | Show hover documentation |
| `<C-k>` | Show signature help (insert mode) |
| `[d` | Go to previous diagnostic |
| `]d` | Go to next diagnostic |
| `<leader>ca` | Show code actions |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format document |

### Preview Keybindings (when `enable_preview_keybindings = true`)

IWE CLI preview generation in markdown files:

| Key | Action |
|-----|--------|
| `<leader>ps` | Generate squash preview |
| `<leader>pe` | Generate export graph preview |
| `<leader>ph` | Generate export with headers preview |
| `<leader>pw` | Generate workspace preview |

### Custom Plug Mappings

All mappings are available as `<Plug>` mappings for custom configuration:

```lua
-- Picker keybindings
vim.keymap.set('n', 'gf', '<Plug>(iwe-picker-find-files)')
vim.keymap.set('n', 'gs', '<Plug>(iwe-picker-paths)')
vim.keymap.set('n', 'ga', '<Plug>(iwe-picker-roots)')
vim.keymap.set('n', 'g/', '<Plug>(iwe-picker-grep)')
vim.keymap.set('n', 'gb', '<Plug>(iwe-picker-blockreferences)')
vim.keymap.set('n', 'gR', '<Plug>(iwe-picker-backlinks)')
vim.keymap.set('n', 'go', '<Plug>(iwe-picker-headers)')

-- LSP keybindings
vim.keymap.set('n', '<CR>', '<Plug>(iwe-lsp-go-to-definition)')
vim.keymap.set('v', '<CR>', '<Plug>(iwe-lsp-link)')
vim.keymap.set('n', '<leader>h', '<Plug>(iwe-lsp-rewrite-list-section)')
vim.keymap.set('n', '<leader>l', '<Plug>(iwe-lsp-rewrite-section-list)')

-- Preview keybindings
vim.keymap.set('n', '<leader>ps', '<Plug>(iwe-preview-squash)')
vim.keymap.set('n', '<leader>pe', '<Plug>(iwe-preview-export)')
vim.keymap.set('n', '<leader>ph', '<Plug>(iwe-preview-export-headers)')
vim.keymap.set('n', '<leader>pw', '<Plug>(iwe-preview-export-workspace)')
```

### Using Enter Key for Navigation and Link Creation

When `enable_markdown_mappings = true`, the `<CR>` (Enter) key provides context-aware functionality:

**Normal mode**: Press `<CR>` to go to the definition of the symbol under the cursor. This works for:
- Navigating to linked files
- Jumping to symbol definitions
- Following references

**Visual mode**: Select text and press `<CR>` to create a link from the selection:
1. Select text in visual mode (e.g., `viw` to select a word)
2. Press `<CR>` (Enter)
3. The LSP will automatically create a link from your selection

This uses the IWE LSP's `custom.link` code action to intelligently link the selected text to the appropriate target in your knowledge base.

## Requirements

**Required:**
- `iwes` LSP server in PATH

**Picker backends (at least one recommended):**
- `nvim-telescope/telescope.nvim` - Full-featured fuzzy finder
- `ibhagwan/fzf-lua` - Fast fzf-based picker
- `folke/snacks.nvim` - Modern picker
- `echasnovski/mini.pick` - Lightweight picker
- Falls back to `vim.ui.select` for LSP-based pickers if none installed

**For Preview Functionality:**
- `iwe` CLI in PATH (install from [iwe-org/iwe](https://github.com/iwe-org/iwe))
- `neato` (Graphviz) for SVG generation

**Recommended:**
- [`MeanderingProgrammer/markdown.nvim`](https://github.com/MeanderingProgrammer/markdown.nvim) - Enhanced markdown rendering that pairs perfectly with IWE's editing features

**Optional:**
- `gitsigns` plugin for git integration

## Health Checks

Run `:checkhealth iwe` to diagnose any issues with:
- LSP server availability
- Picker backend detection
- Project structure
- Dependencies
- Preview functionality (IWE CLI and Graphviz)

## Contributing

This plugin follows modern Neovim development practices with full type safety, comprehensive documentation, and health checks. See `:help iwe` for complete documentation.
