# Changelog

All notable changes to the IWE Neovim plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-12-23

### Added

#### Core Functionality
- **Project Initialization**: `:IWE init` command to create `.iwe` marker directories
- **LSP Integration**: Automatic `iwes` LSP server integration for `.iwe` projects
- **Modern Plugin Architecture**: Type-safe Lua implementation following 2024-2025 best practices

#### Commands
- **`:IWE init`** - Initialize IWE project in current directory
- **`:IWE lsp start/stop/restart/status`** - Control LSP server lifecycle
- **`:IWE telescope find_files/paths/roots/grep/backlinks/headers`** - Launch Telescope pickers
- **`:IWE info`** - Show comprehensive plugin status and configuration

#### Telescope Integration
- **Find Files**: LSP-powered file finding (`gf` equivalent)
- **Workspace Symbols**: Path-based symbol search (`gs` equivalent)
- **Namespace Symbols**: Root-based symbol search (`ga` equivalent)
- **Live Grep**: Search across project files (`g/` equivalent)
- **LSP References**: Backlink navigation (`gb` equivalent)
- **Document Symbols**: Header navigation (`go` equivalent)

#### Key Mappings
- **<Plug> Mapping System**: Flexible mapping system for user customization
- **Default Markdown Mappings**: Writing-focused keybindings for markdown files
  - `-` for checklist formatting
  - `<C-n>`/`<C-p>` for link navigation
  - `z\`` for code block insertion
  - `/d`/`/w` for date/week insertion
  - Undo break mappings for punctuation
- **Configurable Telescope Keybindings**: Optional `gf`, `gs`, `ga`, `g/`, `gr`, `go` mappings
- **Configurable LSP Keybindings**: Optional LSP function mappings
  - `<leader>e/i/h/l/m` for refactoring operations
  - `gD/gd/gi` for navigation
  - `<space>c` for code actions
  - `[d]/]d` for diagnostic navigation

#### Configuration System
- **Type-Safe Configuration**: LuaCATS annotations for all configuration options
- **Granular Control**: Individual toggles for mapping groups (markdown, telescope, LSP)
- **Validation**: Comprehensive configuration validation with error reporting

#### Health Checks
- **`:checkhealth iwe`** - Comprehensive diagnostic system
- **LSP Server Detection**: Verify `iwes` server availability
- **Dependency Checking**: Telescope and optional dependency verification
- **Project Structure Validation**: `.iwe` marker detection

#### Documentation
- **Complete Vimdoc**: Comprehensive `:help iwe` documentation
- **README with Examples**: Full usage examples and configuration options
- **Architecture Documentation**: Modern plugin structure documentation

### Technical Features
- **Auto-initialization**: Automatic setup on plugin load
- **Buffer-local Mappings**: Context-aware keybinding activation
- **Project Detection**: `.iwe` marker-based project identification
- **LSP Auto-start**: Automatic LSP server activation for IWE projects
- **Tab Completion**: Command completion for all IWE subcommands
- **Error Handling**: Comprehensive error reporting and user feedback

### Dependencies
- **Required**:
  - `nvim-telescope/telescope.nvim`
  - `iwes` LSP server
