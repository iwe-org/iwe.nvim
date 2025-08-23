# IWE Neovim Plugin

> **About IWE**: This plugin integrates with the [IWE](https://github.com/iwe-org/iwe) - an LSP/CLI designed for markdown-based knowledge management and note-taking workflows.

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
  'your-username/iwe.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',  -- Required
  },
  config = function()
    require('iwe').setup({
      lsp = {
        cmd = { "iwes" },
        name = "iwes",
        debounce_text_changes = 500,
        auto_format_on_save = true
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
| `:IWE lsp start/stop/restart/status` | Control LSP server |
| `:IWE telescope find_files/paths/roots/grep/backlinks/headers` | Launch Telescope pickers |
| `:IWE info` | Show plugin status and configuration |

## Telescope Integration

The plugin provides LSP-powered Telescope pickers:

- **`:IWE telescope find_files`** - Find files (gf equivalent)
- **`:IWE telescope paths`** - Workspace symbols as paths (gs equivalent)
- **`:IWE telescope roots`** - Namespace symbols as roots (ga equivalent)
- **`:IWE telescope grep`** - Live grep search (g/ equivalent)
- **`:IWE telescope backlinks`** - LSP references as backlinks (gr equivalent)
- **`:IWE telescope headers`** - Document symbols as headers (go equivalent)

## Configuration

The plugin works out of the box, but can be customized:

```lua
require('iwe').setup({
  lsp = {
    cmd = { "iwes" },
    auto_format_on_save = true,
    debounce_text_changes = 500
  },
  mappings = {
    enable_markdown_mappings = true, -- Core markdown editing keybindings
    enable_telescope_keybindings = false, -- Set to true to enable gf, gs, ga, g/, gr, go
    enable_lsp_keybindings = false, -- Set to true to enable LSP keybindings
    leader = "<leader>",
    localleader = "<localleader>"
  },
  telescope = {
    enabled = true,
    setup_config = true,
    load_extensions = { "ui-select", "emoji" }
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
| `gr` | LSP references (backlinks) | `:IWE telescope backlinks` |
| `go` | Document symbols (headers) | `:IWE telescope headers` |

### LSP Keybindings (when `enable_lsp_keybindings = true`)

In markdown files:

| Key | Action |
|-----|--------|
| `<leader>e` | Extract section (refactor) |
| `<leader>i` | Inline reference (refactor) |
| `<leader>h` | Rewrite list section (refactor) |
| `<leader>l` | Rewrite section list (refactor) |
| `<leader>m` | Show code actions |
| `<leader>c` | Rename linked file |
| `gD` | Go to declaration |
| `gd` | Go to definition |
| `gi` | Go to implementation |
| `[d` | Go to previous diagnostic |
| `]d` | Go to next diagnostic |
| `<CR>` | Go to definition |

### Configuration Options

```lua
require('iwe').setup({
  mappings = {
    enable_markdown_mappings = true,        -- Enable markdown editing keybindings
    enable_telescope_keybindings = true,   -- Enable telescope navigation keybindings
    enable_lsp_keybindings = true,         -- Enable LSP keybindings
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
vim.keymap.set('n', 'gr', '<Plug>(iwe-telescope-backlinks)')
vim.keymap.set('n', 'go', '<Plug>(iwe-telescope-headers)')

-- Default LSP keybindings (when enable_lsp_keybindings = true)
vim.keymap.set('n', '<leader>e', '<Plug>(iwe-lsp-extract-section)')
vim.keymap.set('n', '<leader>i', '<Plug>(iwe-lsp-inline-reference)')
vim.keymap.set('n', '<leader>h', '<Plug>(iwe-lsp-rewrite-list-section)')
vim.keymap.set('n', '<leader>l', '<Plug>(iwe-lsp-rewrite-section-list)')
vim.keymap.set('n', '<leader>m', '<Plug>(iwe-lsp-code-action)')
vim.keymap.set('n', '<leader>c', '<Plug>(iwe-lsp-rename)')
vim.keymap.set('n', 'gD', '<Plug>(iwe-lsp-declaration)')
vim.keymap.set('n', 'gd', '<Plug>(iwe-lsp-definition)')
vim.keymap.set('n', 'gi', '<Plug>(iwe-lsp-implementation)')
vim.keymap.set('n', '[d', '<Plug>(iwe-lsp-diagnostic-prev)')
vim.keymap.set('n', ']d', '<Plug>(iwe-lsp-diagnostic-next)')
vim.keymap.set('n', '<CR>', '<Plug>(iwe-lsp-definition)')
```

## Requirements

**Required:**
- `iwes` LSP server in PATH
- `nvim-telescope/telescope.nvim`

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

## Architecture

Modern plugin structure following 2024-2025 best practices:

```
lua/iwe/
├── init.lua         # Main plugin with auto-initialization
├── config.lua       # Type-safe configuration
├── lsp.lua          # LSP integration
├── telescope.lua    # Telescope pickers
├── commands.lua     # User commands
├── mappings.lua     # Key mappings
└── health.lua       # Health diagnostics
```

## `.iwe` Directory Structure

The `.iwe` marker directory identifies IWE project roots:

```
your-notes/
├── .iwe/           # Marker directory (created by :IWE init)
├── index.md        # Your notes
├── projects/
│   └── readme.md
└── ideas/
    └── brainstorm.md
```

This approach allows you to have multiple IWE projects and easily discover them with Telescope.

## Contributing

This plugin follows modern Neovim development practices with full type safety, comprehensive documentation, and health checks. See `:help iwe` for complete documentation.
