---@class IWE.Preview
local M = {}

local config = require('iwe.config')

---Get the IWE project root for the current buffer, or for the current
---directory when the buffer has no file
---@return string|nil
local function get_project_root()
  return require('iwe').get_project_root()
end

---Get the current file key: the buffer's path relative to the project root,
---without its extension, as IWE names documents (`plans/example-plan`)
---@return string|nil
local function get_current_file_key()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then
    return nil
  end

  local root = get_project_root()
  if not root then
    return nil
  end

  local path = vim.fs.normalize(vim.fn.fnamemodify(bufname, ':p'))
  local prefix = vim.fs.normalize(root) .. '/'
  if path:sub(1, #prefix) ~= prefix then
    return nil
  end

  local key = vim.fn.fnamemodify(path:sub(#prefix + 1), ':r')
  if key == '' then
    return nil
  end

  return key
end

---Check if required dependencies are available
---@return boolean success
---@return string? error_message
local function check_dependencies()
  -- Check for iwe CLI
  if vim.fn.executable('iwe') == 0 then
    return false, "iwe CLI not found in PATH. Please install IWE CLI."
  end

  -- Check for neato (Graphviz)
  if vim.fn.executable('neato') == 0 then
    return false, "neato not found in PATH. Please install Graphviz."
  end

  return true, nil
end

---Ensure output directory exists
---@param output_dir string
---@return boolean success
local function ensure_output_dir(output_dir)
  local success = vim.fn.mkdir(output_dir, 'p')
  return success == 1 or vim.fn.isdirectory(output_dir) == 1
end

---Resolve the project root and create the directory that will hold `output_file`
---@param output_file string
---@return string|nil root
---@return string? error_message
local function prepare(output_file)
  local success, error_msg = check_dependencies()
  if not success then
    return nil, error_msg
  end

  local root = get_project_root()
  if not root then
    return nil, "Not in an IWE project (no .iwe directory found)"
  end

  local output_dir = vim.fs.dirname(output_file)
  if not ensure_output_dir(output_dir) then
    return nil, "Failed to create output directory: " .. output_dir
  end

  return root
end

---Describe a failed command from its result
---@param result vim.SystemCompleted
---@return string
local function failure_message(result)
  local stderr = vim.trim(result.stderr or '')
  if stderr ~= '' then
    return stderr
  end
  return "Command failed with exit code " .. result.code
end

---Run `iwe` in the project root and hand its stdout to `on_success`
---@param args string[] Arguments after `iwe`
---@param root string Project root
---@param on_success fun(stdout: string)
---@param on_error fun(message: string)
local function run_iwe(args, root, on_success, on_error)
  local cmd = vim.list_extend({ 'iwe' }, args)
  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        on_success(result.stdout or '')
      else
        on_error(failure_message(result))
      end
    end)
  end)
end

---Export a DOT graph with `iwe export` and render it to SVG with `neato`
---@param export_args string[] Arguments after `iwe export`
---@param output_file string
---@param on_success fun()
---@param on_error fun(message: string)
local function render_export(export_args, output_file, on_success, on_error)
  local root, error_msg = prepare(output_file)
  if not root then
    on_error(error_msg)
    return
  end

  local args = vim.list_extend({ 'export', '--format', 'dot' }, export_args)
  run_iwe(args, root, function(dot)
    vim.system({ 'neato', '-Tsvg', '-o', output_file }, { stdin = dot, text = true }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          on_success()
        else
          on_error(failure_message(result))
        end
      end)
    end)
  end, on_error)
end

---Open a generated SVG with the system default application
---@param output_file string
local function open_svg(output_file)
  vim.system({ 'open', output_file }, {}, function() end)
end

---Generate squashed markdown preview
---@param file_key? string Optional file key, uses current buffer if not provided
function M.generate_squash_preview(file_key)
  local key = file_key or get_current_file_key()
  if not key then
    vim.notify("No file key available. Save the current buffer or provide a key.", vim.log.levels.ERROR)
    return
  end

  local preview_config = config.get().preview
  local output_file = preview_config.output_dir .. "/" .. key .. "-preview.md"

  local function on_error(error)
    vim.notify("Failed to generate squash preview: " .. error, vim.log.levels.ERROR)
  end

  local root, error_msg = prepare(output_file)
  if not root then
    on_error(error_msg)
    return
  end

  run_iwe({ 'squash', '--depth', '3', key }, root, function(markdown)
    if vim.fn.writefile(vim.split(markdown, '\n', { plain = true }), output_file, 'b') ~= 0 then
      on_error("Failed to write " .. output_file)
      return
    end
    vim.notify("Squash preview generated: " .. output_file)
    if preview_config.auto_open then
      vim.cmd.edit(vim.fn.fnameescape(output_file))
    end
  end, on_error)
end

---Generate basic export DOT SVG
---@param file_key? string Optional file key, uses current buffer if not provided
function M.generate_export_preview(file_key)
  local key = file_key or get_current_file_key()
  if not key then
    vim.notify("No file key available. Save the current buffer or provide a key.", vim.log.levels.ERROR)
    return
  end

  local preview_config = config.get().preview
  local output_file = preview_config.output_dir .. "/" .. key .. "-graph.svg"

  render_export({ '--key', key, '--depth', '2' }, output_file, function()
    vim.notify("Export preview generated: " .. output_file)
    if preview_config.auto_open then
      open_svg(output_file)
    end
  end, function(error)
    vim.notify("Failed to generate export preview: " .. error, vim.log.levels.ERROR)
  end)
end

---Generate export DOT SVG with headers
---@param file_key? string Optional file key, uses current buffer if not provided
function M.generate_export_headers_preview(file_key)
  local key = file_key or get_current_file_key()
  if not key then
    vim.notify("No file key available. Save the current buffer or provide a key.", vim.log.levels.ERROR)
    return
  end

  local preview_config = config.get().preview
  local output_file = preview_config.output_dir .. "/" .. key .. "-headers.svg"

  render_export({ '--key', key, '--depth', '2', '--include-headers' }, output_file, function()
    vim.notify("Export headers preview generated: " .. output_file)
    if preview_config.auto_open then
      open_svg(output_file)
    end
  end, function(error)
    vim.notify("Failed to generate export headers preview: " .. error, vim.log.levels.ERROR)
  end)
end

---Generate full workspace export DOT SVG
function M.generate_export_workspace_preview()
  local preview_config = config.get().preview
  local output_file = preview_config.output_dir .. "/workspace.svg"

  render_export({ '--depth', '1' }, output_file, function()
    vim.notify("Workspace preview generated: " .. output_file)
    if preview_config.auto_open then
      open_svg(output_file)
    end
  end, function(error)
    vim.notify("Failed to generate workspace preview: " .. error, vim.log.levels.ERROR)
  end)
end

---Check if preview functionality is available
---@return boolean
function M.is_available()
  local success, _ = check_dependencies()
  return success
end

---Get preview status information
---@return table
function M.get_status()
  local status = {
    iwe_available = vim.fn.executable('iwe') == 1,
    neato_available = vim.fn.executable('neato') == 1,
    output_dir = config.get().preview.output_dir,
    current_file_key = get_current_file_key()
  }

  status.output_dir_writable = ensure_output_dir(status.output_dir)
  status.ready = status.iwe_available and status.neato_available and status.output_dir_writable

  return status
end

return M
