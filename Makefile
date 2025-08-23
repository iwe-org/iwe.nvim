.PHONY: test lint format check health install-deps clean

# Default target
all: test

# Install testing dependencies
install-deps:
	@echo "Installing testing dependencies..."
	@mkdir -p ~/.local/share/nvim/site/pack/vendor/start/
	@if [ ! -d ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim ]; then \
		git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim; \
	fi
	@if [ ! -d ~/.local/share/nvim/site/pack/vendor/start/telescope.nvim ]; then \
		git clone https://github.com/nvim-telescope/telescope.nvim ~/.local/share/nvim/site/pack/vendor/start/telescope.nvim; \
	fi

# Run all tests
test: install-deps
	@echo "Running tests..."
	timeout 30s nvim --headless \
		--noplugin \
		-u tests/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('tests/', {minimal_init = 'tests/minimal_init.lua'})" || \
	(echo "Tests timed out or failed"; exit 1)

# Run linting
lint:
	@echo "Running luacheck..."
	@if command -v luacheck >/dev/null 2>&1; then \
		luacheck lua/ tests/ --globals vim; \
	else \
		echo "luacheck not found. Install with: luarocks install luacheck"; \
		echo "Skipping linting..."; \
	fi

# Format code
format:
	@echo "Formatting code..."
	@if command -v stylua >/dev/null 2>&1; then \
		stylua lua/ tests/; \
	else \
		echo "stylua not found. Install with: cargo install stylua"; \
	fi

# Check formatting
check-format:
	@echo "Checking formatting..."
	@if command -v stylua >/dev/null 2>&1; then \
		stylua --check lua/ tests/; \
	else \
		echo "stylua not found. Install with: cargo install stylua"; \
	fi

# Run health check
health: install-deps
	@echo "Running health check..."
	@mkdir -p /tmp/iwe-test/.iwe
	@cd /tmp/iwe-test && \
	nvim --headless \
		--noplugin \
		-u $(PWD)/tests/minimal_init.lua \
		-c "lua package.path = package.path .. ';$(PWD)/lua/?.lua'" \
		-c "lua require('iwe').setup()" \
		-c "checkhealth iwe" \
		-c "qa!"
	@rm -rf /tmp/iwe-test

# Run all checks
check: lint check-format test health

# Clean up
clean:
	@echo "Cleaning up..."
	@rm -rf /tmp/iwe-test*