---@class IWE.Commands
local M = {}

local lsp = require('iwe.lsp')
local telescope = require('iwe.telescope')


---Get completion for LSP commands
---@return string[]
local function complete_lsp_commands()
  return { 'start', 'stop', 'restart', 'status' }
end

---Get completion for Telescope commands
---@return string[]
local function complete_telescope_commands()
  return { 'find_files', 'paths', 'roots', 'grep', 'backlinks', 'headers', 'setup' }
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
  else
    vim.notify(string.format("Unknown LSP command: %s", subcmd), vim.log.levels.ERROR)
  end
end

---Handle Telescope subcommands
---@param subcmd string The subcommand (files, project, grep, nav, setup)
local function handle_telescope_command(subcmd)
  if not telescope.is_available() then
    vim.notify("Telescope not available - please install nvim-telescope/telescope.nvim", vim.log.levels.ERROR)
    return
  end

  if subcmd == 'find_files' then
    telescope.pickers.find_files()
  elseif subcmd == 'paths' then
    telescope.pickers.paths()
  elseif subcmd == 'roots' then
    telescope.pickers.roots()
  elseif subcmd == 'grep' then
    telescope.pickers.grep()
  elseif subcmd == 'backlinks' then
    telescope.pickers.backlinks()
  elseif subcmd == 'headers' then
    telescope.pickers.headers()
  elseif subcmd == 'setup' then
    telescope.setup()
    vim.notify("Telescope configuration applied")
  else
    vim.notify(string.format("Unknown Telescope command: %s", subcmd), vim.log.levels.ERROR)
  end
end

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

  if subcmd == 'lsp' then
    if #args < 2 then
      vim.notify("Usage: IWE lsp <start|stop|restart|status>", vim.log.levels.ERROR)
      return
    end
    handle_lsp_command(args[2])
  elseif subcmd == 'telescope' or subcmd == 'tel' then
    if #args < 2 then
      vim.notify("Usage: IWE telescope <files|project|grep|nav|setup>", vim.log.levels.ERROR)
      return
    end
    handle_telescope_command(args[2])
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
      string.format("  Debounce: %dms", config.lsp.debounce_text_changes),
      "",
      "Mappings Configuration:",
      string.format("  Markdown Mappings: %s", config.mappings.enable_markdown_mappings),
      string.format("  Telescope Keybindings: %s", config.mappings.enable_telescope_keybindings),
      string.format("  LSP Keybindings: %s", config.mappings.enable_lsp_keybindings),
      string.format("  Leader: %s", config.mappings.leader),
      string.format("  Local Leader: %s", config.mappings.localleader),
      "",
      "Telescope Configuration:",
      string.format("  Enabled: %s", config.telescope.enabled),
      string.format("  Setup Config: %s", config.telescope.setup_config),
      string.format("  Extensions: %s", table.concat(config.telescope.load_extensions, ", ")),
      "",
      "Status:",
      string.format("  LSP Available: %s", lsp.is_available() and "Yes" or "No")
    }

    local clients = vim.lsp.get_clients({ name = 'iwes' })
    table.insert(lines, string.format("  LSP Running: %s", #clients > 0 and "Yes" or "No"))
    table.insert(lines, string.format("  Telescope Available: %s", telescope.is_available() and "Yes" or "No"))

    -- Check for .iwe marker in current directory
    local iwe_root = vim.fs.root(0, {'.iwe'})
    table.insert(lines, string.format("  IWE Project Root: %s", iwe_root or "Not found"))

    -- Print each line separately to ensure proper formatting
    for _, line in ipairs(lines) do
      print(line)
    end
  else
    vim.notify(string.format("Unknown IWE command: %s", subcmd), vim.log.levels.ERROR)
    vim.notify("Available commands: lsp, telescope, init, info", vim.log.levels.INFO)
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
    local subcommands = { 'lsp', 'telescope', 'tel', 'init', 'info' }
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