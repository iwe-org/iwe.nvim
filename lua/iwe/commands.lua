---@class IWE.Commands
local M = {}

local lsp = require('iwe.lsp')
local picker = require('iwe.picker')
local preview = require('iwe.preview')


---Get completion for LSP commands
---@return string[]
local function complete_lsp_commands()
  return { 'start', 'stop', 'restart', 'status', 'toggle_inlay_hints' }
end

---Get completion for Telescope commands (deprecated, kept for backward compatibility)
---@return string[]
local function complete_telescope_commands()
  return { 'find_files', 'paths', 'roots', 'grep', 'blockreferences', 'backlinks', 'headers', 'setup' }
end

---Get completion for Preview commands
---@return string[]
local function complete_preview_commands()
  return { 'squash', 'export', 'export-headers', 'export-workspace' }
end

---Initialize IWE project in current directory
local function init_iwe_project()
  local cwd = vim.fn.getcwd()
  local iwe_dir = cwd .. '/.iwe'

  if vim.fn.isdirectory(iwe_dir) == 1 then
    vim.notify("IWE project already initialized in " .. cwd, vim.log.levels.INFO)
    return
  end

  -- Check if iwe command is available
  if vim.fn.executable('iwe') == 1 then
    -- Use external iwe init command if available
    local result = vim.fn.system('iwe init')
    if vim.v.shell_error == 0 then
      vim.notify("IWE project initialized successfully", vim.log.levels.INFO)
    else
      vim.notify("Failed to initialize IWE project: " .. result, vim.log.levels.ERROR)
    end
  else
    -- Fallback: create .iwe directory manually
    local success = vim.fn.mkdir(iwe_dir, 'p')
    if success == 1 then
      vim.notify("IWE project initialized at " .. iwe_dir, vim.log.levels.INFO)
      vim.notify("Note: Install 'iwe' command for full functionality", vim.log.levels.WARN)
    else
      vim.notify("Failed to create .iwe directory", vim.log.levels.ERROR)
    end
  end
end

---Handle LSP subcommands
---@param subcmd string The subcommand (start, stop, restart, status)
local function handle_lsp_command(subcmd)
  if subcmd == 'start' then
    lsp.start()
    vim.notify("Started IWE LSP server")
  elseif subcmd == 'stop' then
    local clients = vim.lsp.get_clients({ name = 'iwes' })
    for _, client in ipairs(clients) do
      client.stop()
    end
    vim.notify("Stopped IWE LSP server")
  elseif subcmd == 'restart' then
    local clients = vim.lsp.get_clients({ name = 'iwes' })
    for _, client in ipairs(clients) do
      client.stop()
    end
    vim.defer_fn(function()
      lsp.start()
      vim.notify("Restarted IWE LSP server")
    end, 500)
  elseif subcmd == 'status' then
    local clients = vim.lsp.get_clients({ name = 'iwes' })
    if #clients > 0 then
      vim.notify(string.format("IWE LSP server is running (%d client%s)",
        #clients, #clients == 1 and "" or "s"))
    else
      vim.notify("IWE LSP server is not running")
    end
  elseif subcmd == 'toggle_inlay_hints' then
    lsp.toggle_inlay_hints()
  else
    vim.notify(string.format("Unknown LSP command: %s", subcmd), vim.log.levels.ERROR)
  end
end

---Handle picker subcommands
---@param subcmd string The subcommand (find_files, paths, roots, grep, blockreferences, backlinks, headers)
local function handle_picker_command(subcmd)
  if subcmd == 'find_files' then
    picker.find_files()
  elseif subcmd == 'paths' then
    picker.paths()
  elseif subcmd == 'roots' then
    picker.roots()
  elseif subcmd == 'grep' then
    picker.grep()
  elseif subcmd == 'blockreferences' then
    picker.blockreferences()
  elseif subcmd == 'backlinks' then
    picker.backlinks()
  elseif subcmd == 'headers' then
    picker.headers()
  else
    vim.notify(string.format("Unknown picker command: %s", subcmd), vim.log.levels.ERROR)
  end
end

---Handle Telescope subcommands (deprecated, kept for backward compatibility)
---@param subcmd string The subcommand
local function handle_telescope_command(subcmd)
  vim.notify("IWE: ':IWE telescope' is deprecated, use ':IWE <command>' directly instead", vim.log.levels.WARN)

  if subcmd == 'setup' then
    -- Special case: telescope setup still uses the telescope module
    local telescope = require('iwe.telescope')
    if telescope.is_available() then
      telescope.setup()
      vim.notify("Telescope configuration applied")
    else
      vim.notify("Telescope not available", vim.log.levels.ERROR)
    end
    return
  end

  -- Delegate to picker for other commands
  handle_picker_command(subcmd)
end

---Handle Preview subcommands
---@param subcmd string The subcommand (squash, export, export-headers, export-workspace)
local function handle_preview_command(subcmd)
  if not preview.is_available() then
    vim.notify("Preview not available - please install iwe CLI and neato (Graphviz)", vim.log.levels.ERROR)
    return
  end

  if subcmd == 'squash' then
    preview.generate_squash_preview()
  elseif subcmd == 'export' then
    preview.generate_export_preview()
  elseif subcmd == 'export-headers' then
    preview.generate_export_headers_preview()
  elseif subcmd == 'export-workspace' then
    preview.generate_export_workspace_preview()
  else
    vim.notify(string.format("Unknown Preview command: %s", subcmd), vim.log.levels.ERROR)
  end
end

---List of picker commands for direct invocation
local picker_commands = {
  find_files = true,
  paths = true,
  roots = true,
  grep = true,
  blockreferences = true,
  backlinks = true,
  headers = true,
}

---Main IWE command handler
---@param opts table Command options from nvim_create_user_command
local function iwe_command(opts)
  local args = opts.fargs

  if #args == 0 then
    -- Show help when no arguments
    vim.cmd('help iwe')
    return
  end

  local subcmd = args[1]

  -- Direct picker commands (new syntax: :IWE find_files, :IWE paths, etc.)
  if picker_commands[subcmd] then
    handle_picker_command(subcmd)
    return
  end

  if subcmd == 'lsp' then
    if #args < 2 then
      vim.notify("Usage: IWE lsp <start|stop|restart|status|toggle_inlay_hints>", vim.log.levels.ERROR)
      return
    end
    handle_lsp_command(args[2])
  elseif subcmd == 'telescope' or subcmd == 'tel' then
    -- Deprecated: kept for backward compatibility
    if #args < 2 then
      vim.notify("Usage: IWE telescope <find_files|paths|roots|...>", vim.log.levels.ERROR)
      return
    end
    handle_telescope_command(args[2])
  elseif subcmd == 'preview' or subcmd == 'prev' then
    if #args < 2 then
      vim.notify("Usage: IWE preview <squash|export|export-headers|export-workspace>", vim.log.levels.ERROR)
      return
    end
    handle_preview_command(args[2])
  elseif subcmd == 'init' then
    init_iwe_project()
  elseif subcmd == 'info' then
    local config = require('iwe.config').get()
    local lines = {
      "IWE Plugin Information:",
      "",
      "LSP Configuration:",
      string.format("  Command: %s", table.concat(config.lsp.cmd, " ")),
      string.format("  Name: %s", config.lsp.name),
      string.format("  Auto Format: %s", config.lsp.auto_format_on_save),
      string.format("  Inlay Hints: %s", config.lsp.enable_inlay_hints),
      string.format("  Debounce: %dms", config.lsp.debounce_text_changes),
      "",
      "Mappings Configuration:",
      string.format("  Markdown Mappings: %s", config.mappings.enable_markdown_mappings),
      string.format("  Picker Keybindings: %s", config.mappings.enable_picker_keybindings),
      string.format("  LSP Keybindings: %s", config.mappings.enable_lsp_keybindings),
      string.format("  Leader: %s", config.mappings.leader),
      string.format("  Local Leader: %s", config.mappings.localleader),
      "",
      "Picker Configuration:",
      string.format("  Backend: %s",
        type(config.picker.backend) == "function" and "custom function" or config.picker.backend),
      string.format("  Fallback Notify: %s", config.picker.fallback_notify),
      "",
      "Preview Configuration:",
      string.format("  Output Dir: %s", config.preview.output_dir),
      string.format("  Auto Open: %s", config.preview.auto_open),
      "",
      "Status:",
      string.format("  LSP Available: %s", lsp.is_available() and "Yes" or "No")
    }

    local clients = vim.lsp.get_clients({ name = 'iwes' })
    table.insert(lines, string.format("  LSP Running: %s", #clients > 0 and "Yes" or "No"))
    table.insert(lines, string.format("  Picker Backend: %s", picker.get_backend() or "none"))
    table.insert(lines, string.format("  Available Backends: %s", table.concat(picker.list_backends(), ", ")))
    table.insert(lines, string.format("  Preview Available: %s", preview.is_available() and "Yes" or "No"))

    -- Check for .iwe marker in current directory
    local iwe_root = vim.fs.root(0, {'.iwe'})
    table.insert(lines, string.format("  IWE Project Root: %s", iwe_root or "Not found"))

    -- Print each line separately to ensure proper formatting
    for _, line in ipairs(lines) do
      print(line)
    end
  else
    vim.notify(string.format("Unknown IWE command: %s", subcmd), vim.log.levels.ERROR)
    vim.notify("Available: find_files, paths, roots, grep, backlinks, headers, lsp, preview, init, info",
      vim.log.levels.INFO)
  end
end

---Complete function for IWE command
---@param arg_lead string Current argument being completed
---@param cmd_line string Full command line
---@param _ number Cursor position
---@return string[]
local function complete_iwe_command(arg_lead, cmd_line, _)
  local args = vim.split(cmd_line, '%s+')
  local arg_count = #args - 1  -- Subtract 1 for the command itself

  -- If we're completing the first argument after IWE
  if arg_count == 1 then
    -- Include both picker commands and subcommand groups
    local subcommands = {
      -- Direct picker commands (new)
      'find_files', 'paths', 'roots', 'grep', 'blockreferences', 'backlinks', 'headers',
      -- Command groups
      'lsp', 'preview', 'prev', 'init', 'info',
      -- Deprecated (kept for backward compatibility)
      'telescope', 'tel',
    }
    return vim.tbl_filter(function(cmd)
      return cmd:find('^' .. vim.pesc(arg_lead))
    end, subcommands)
  end

  -- If we're completing the second argument
  if arg_count == 2 then
    local subcmd = args[2]
    if subcmd == 'lsp' then
      return complete_lsp_commands()
    elseif subcmd == 'telescope' or subcmd == 'tel' then
      return complete_telescope_commands()
    elseif subcmd == 'preview' or subcmd == 'prev' then
      return complete_preview_commands()
    end
  end

  return {}
end

---Setup user commands
function M.setup()
  vim.api.nvim_create_user_command('IWE', iwe_command, {
    nargs = '*',
    complete = complete_iwe_command,
    desc = 'IWE plugin commands'
  })
end

return M