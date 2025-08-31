# IWE Neovim Plugin

**About IWE**: This plugin integrates with the [IWE](https://github.com/iwe-org/iwe) - an LSP/CLI designed for markdown-based knowledge management and note-taking workflows.

You can learn more at [IWE.md](https://iwe.md)

## Features

- **🏗️ Project Initialization**: Create IWE projects with `:IWE init`
- **🔍 LSP Integration**: Automatically starts `iwes` LSP server for `.iwe` projects
- **🔭 Telescope Integration**: Find IWE files across all your projects
- **📝 Markdown Enhancements**: Writing-focused features for markdown editing
- **⚙️ Modern Architecture**: Type-safe, well-documented, with health checks

## Getting Started

### 1. Install the Plugin

Add to your Neovim configuration (using lazy.nvim):

```lua
{
  'iwe-org/iwe.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',  -- Required
  },
  config = function()
    require('iwe').setup({
      lsp = {
        cmd = { "iwes" },
        name = "iwes",
        debounce_text_changes = 500,
        auto_format_on_save = true,
        enable_inlay_hints = true
      },
      mappings = {
        enable_markdown_mappings = true,
        enable_telescope_keybindings = false,
        enable_lsp_keybindings = false,
        leader = "<leader>",
        localleader = "<localleader>"
      },
      telescope = {
        enabled = true,
        setup_config = true,
        load_extensions = { "ui-select", "emoji" }
      }
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
- Telescope integration is working
- Plugin configuration is valid

### 3. Initialize Your First IWE Directory

Navigate to your notes directory and run:

```vim
:IWE init
```

This creates a `.iwe` marker directory that:
- Identifies this directory as an IWE project root
- Enables LSP server integration
- Makes the project discoverable by Telescope

### 4. Start Writing

Open any `.md` file in your IWE project and enjoy:
- Automatic LSP server integration
- Enhanced markdown editing features
- Seamless project-wide file navigation

## Commands

| Command | Description |
|---------|-------------|
| `:IWE init` | Initialize IWE project in current directory |
| `:IWE lsp start/stop/restart/status/toggle_inlay_hints` | Control LSP server |
| `:IWE telescope find_files/paths/roots/grep/backlinks/headers` | Launch Telescope pickers |
| `:IWE preview squash/export/export-headers/export-workspace` | Generate previews using IWE CLI |
| `:IWE info` | Show plugin status and configuration |

## Telescope Integration

The plugin provides LSP-powered Telescope pickers:

- **`:IWE telescope find_files`** - Find files (gf equivalent)
- **`:IWE telescope paths`** - Workspace symbols as paths (gs equivalent)
- **`:IWE telescope roots`** - Namespace symbols as roots (ga equivalent)
- **`:IWE telescope grep`** - Live grep search (g/ equivalent)
- **`:IWE telescope backlinks`** - LSP references as backlinks (gb equivalent)
- **`:IWE telescope headers`** - Document symbols as headers (go equivalent)

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
    enable_markdown_mappings = true, -- Core markdown editing keybindings
    enable_telescope_keybindings = false, -- Set to true to enable gf, gs, ga, g/, gb, go
    enable_lsp_keybindings = false, -- Set to true to enable IWE-specific LSP keybindings
    enable_preview_keybindings = false, -- Set to true to enable preview keybindings
    leader = "<leader>",
    localleader = "<localleader>"
  },
  telescope = {
    enabled = true,
    setup_config = true,
    load_extensions = { "ui-select", "emoji" }
  },
  preview = {
    output_dir = "~/tmp/preview", -- Directory for generated preview files
    temp_dir = "/tmp", -- Directory for temporary files
    auto_open = false -- Whether to automatically open generated previews
  }
})
```

## Default Key Mappings

### Markdown Editing (when `enable_markdown_mappings = true`)

In markdown files:

| Key | Action |
|-----|--------|
| `-` | Format current line as checklist item |
| `<C-n>` | Navigate to next link |
| `<C-p>` | Navigate to previous link |
| `/d` | Insert current date |
| `/w` | Insert current week |

### Telescope Navigation (when `enable_telescope_keybindings = true`)

In markdown files:

| Key | Action | Command Equivalent |
|-----|--------|--------------------|
| `gf` | Find files | `:IWE telescope find_files` |
| `gs` | Workspace symbols (paths) | `:IWE telescope paths` |
| `ga` | Namespace symbols (roots) | `:IWE telescope roots` |
| `g/` | Live grep search | `:IWE telescope grep` |
| `gb` | LSP references (backlinks) | `:IWE telescope backlinks` |
| `go` | Document symbols (headers) | `:IWE telescope headers` |

### IWE LSP Keybindings (when `enable_lsp_keybindings = true`)

IWE-specific refactoring actions in markdown files:

| Key | Action |
|-----|--------|
| `<leader>e` | Extract section (refactor) |
| `<leader>i` | Inline reference (refactor) |
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

### Configuration Options

```lua
require('iwe').setup({
  mappings = {
    enable_markdown_mappings = true,        -- Enable markdown editing keybindings
    enable_telescope_keybindings = true,   -- Enable telescope navigation keybindings
    enable_lsp_keybindings = true,         -- Enable IWE-specific LSP keybindings
    enable_preview_keybindings = true,     -- Enable preview keybindings
  }
})
```

All mappings are available as `<Plug>` mappings for custom configuration:

```lua
-- Default Telescope keybindings (when enable_telescope_keybindings = true)
vim.keymap.set('n', 'gf', '<Plug>(iwe-telescope-find-files)')
vim.keymap.set('n', 'gs', '<Plug>(iwe-telescope-paths)')
vim.keymap.set('n', 'ga', '<Plug>(iwe-telescope-roots)')
vim.keymap.set('n', 'g/', '<Plug>(iwe-telescope-grep)')
vim.keymap.set('n', 'gb', '<Plug>(iwe-telescope-backlinks)')
vim.keymap.set('n', 'go', '<Plug>(iwe-telescope-headers)')

-- IWE-specific LSP keybindings (when enable_lsp_keybindings = true)
vim.keymap.set('n', '<leader>e', '<Plug>(iwe-lsp-extract-section)')
vim.keymap.set('n', '<leader>i', '<Plug>(iwe-lsp-inline-reference)')
vim.keymap.set('n', '<leader>h', '<Plug>(iwe-lsp-rewrite-list-section)')
vim.keymap.set('n', '<leader>l', '<Plug>(iwe-lsp-rewrite-section-list)')

-- Preview keybindings (when enable_preview_keybindings = true)
vim.keymap.set('n', '<leader>ps', '<Plug>(iwe-preview-squash)')
vim.keymap.set('n', '<leader>pe', '<Plug>(iwe-preview-export)')
vim.keymap.set('n', '<leader>ph', '<Plug>(iwe-preview-export-headers)')
vim.keymap.set('n', '<leader>pw', '<Plug>(iwe-preview-export-workspace)')
```

## Requirements

**Required:**
- `iwes` LSP server in PATH
- `nvim-telescope/telescope.nvim`

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
- Telescope integration
- Project structure
- Dependencies
- Preview functionality (IWE CLI and Graphviz)

## Contributing

This plugin follows modern Neovim development practices with full type safety, comprehensive documentation, and health checks. See `:help iwe` for complete documentation.
