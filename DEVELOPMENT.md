# Development Guide

This guide covers setting up the development environment and running tests for the IWE Neovim plugin.

## Prerequisites

- Neovim 0.9.5 or later
- Git
- Make

## Development Dependencies

### Required for Testing
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Testing framework (auto-installed by `make`)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Required dependency (auto-installed by `make`)

### Optional for Code Quality
- **luacheck** - Lua linter
  ```bash
  # Install via LuaRocks (if you have it)
  luarocks install luacheck
  
  # Or via package manager
  # macOS:
  brew install luacheck
  
  # Ubuntu/Debian:
  sudo apt install luacheck
  ```

- **stylua** - Lua formatter
  ```bash
  # Install via Cargo (if you have Rust)
  cargo install stylua
  
  # Or via package manager
  # macOS:
  brew install stylua
  ```

## Running Tests

```bash
# Run all tests (this is usually what you want)
make test

# Run tests with linting (if luacheck is installed)
make check

# Run just the health check
make health

# Run linting only
make lint

# Format code
make format
```

## Test Structure

```
tests/
├── minimal_init.lua     # Minimal Neovim config for tests
├── helpers.lua          # Test utilities
├── iwe_spec.lua         # Unit tests
└── integration_spec.lua # Integration tests
```

## Manual Testing

You can also test the plugin manually by symlinking it:

```bash
# Create symlink for lazy.nvim
ln -s /path/to/iwe.nvim ~/.local/share/nvim/lazy/iwe.nvim

# Or use in your Neovim config
{
  dir = '/path/to/your/iwe.nvim',
  name = 'iwe.nvim',
  config = function()
    require('iwe').setup()
  end
}
```

## Debugging Tests

To debug failing tests, you can run Neovim with the test configuration:

```bash
nvim -u tests/minimal_init.lua
```

Then manually run commands or inspect the plugin state.

## Code Quality

The project uses:
- **luacheck** for static analysis
- **stylua** for consistent formatting
- **plenary.nvim** for testing

Run `make check` to run all quality checks, or individual commands:
- `make lint` - Run luacheck
- `make format` - Format with stylua  
- `make test` - Run test suite