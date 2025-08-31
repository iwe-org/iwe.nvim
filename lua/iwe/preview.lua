---@class IWE.Preview
local M = {}

local config = require('iwe.config')

---Get the current file key (filename without extension)
---@return string|nil
local function get_current_file_key()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then
    return nil
  end
  
  local filename = vim.fn.fnamemodify(bufname, ':t:r')
  if filename == '' then
    return nil
  end
  
  return filename
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

---Execute command asynchronously and handle output
---@param cmd string[]
---@param output_file string
---@param on_success function
---@param on_error function
local function execute_async(cmd, output_file, on_success, on_error)
  local success, error_msg = check_dependencies()
  if not success then
    on_error(error_msg)
    return
  end
  
  vim.system(cmd, {
    stdout = output_file and vim.uv.fs_open(output_file, 'w', 420) or nil,
    stderr = true,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        on_success(output_file)
      else
        local error_message = result.stderr and result.stderr or "Command failed with exit code " .. result.code
        on_error(error_message)
      end
    end)
  end)
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
  local output_dir = preview_config.output_dir
  local temp_dir = preview_config.temp_dir
  
  if not ensure_output_dir(output_dir) then
    vim.notify("Failed to create output directory: " .. output_dir, vim.log.levels.ERROR)
    return
  end
  
  local output_file = output_dir .. "/" .. key .. "-preview.md"
  local cmd = { 'iwe', 'squash', '-d', '3', '--key', key }
  
  execute_async(cmd, output_file, function(file)
    vim.notify("Squash preview generated: " .. file)
    if preview_config.auto_open then
      vim.cmd('edit ' .. file)
    end
  end, function(error)
    vim.notify("Failed to generate squash preview: " .. error, vim.log.levels.ERROR)
  end)
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
  local output_dir = preview_config.output_dir
  
  if not ensure_output_dir(output_dir) then
    vim.notify("Failed to create output directory: " .. output_dir, vim.log.levels.ERROR)
    return
  end
  
  local output_file = output_dir .. "/" .. key .. "-graph.svg"
  local cmd = { 'sh', '-c', 
    string.format('iwe export dot --key %s -d 2 | neato -Tsvg -o %s', 
      vim.fn.shellescape(key), vim.fn.shellescape(output_file)) }
  
  execute_async(cmd, nil, function()
    vim.notify("Export preview generated: " .. output_file)
    if preview_config.auto_open then
      -- Try to open SVG with system default application
      vim.system({ 'open', output_file }, {}, function() end)
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
  local output_dir = preview_config.output_dir
  
  if not ensure_output_dir(output_dir) then
    vim.notify("Failed to create output directory: " .. output_dir, vim.log.levels.ERROR)
    return
  end
  
  local output_file = output_dir .. "/" .. key .. "-headers.svg"
  local cmd = { 'sh', '-c', 
    string.format('iwe export dot --key %s -d 2 --include-headers | neato -Tsvg -o %s', 
      vim.fn.shellescape(key), vim.fn.shellescape(output_file)) }
  
  execute_async(cmd, nil, function()
    vim.notify("Export headers preview generated: " .. output_file)
    if preview_config.auto_open then
      -- Try to open SVG with system default application
      vim.system({ 'open', output_file }, {}, function() end)
    end
  end, function(error)
    vim.notify("Failed to generate export headers preview: " .. error, vim.log.levels.ERROR)
  end)
end

---Generate full workspace export DOT SVG
function M.generate_export_workspace_preview()
  local preview_config = config.get().preview
  local output_dir = preview_config.output_dir
  
  if not ensure_output_dir(output_dir) then
    vim.notify("Failed to create output directory: " .. output_dir, vim.log.levels.ERROR)
    return
  end
  
  local output_file = output_dir .. "/workspace.svg"
  local cmd = { 'sh', '-c', 
    string.format('iwe export dot -d 1 | neato -Tsvg -o %s', 
      vim.fn.shellescape(output_file)) }
  
  execute_async(cmd, nil, function()
    vim.notify("Workspace preview generated: " .. output_file)
    if preview_config.auto_open then
      -- Try to open SVG with system default application
      vim.system({ 'open', output_file }, {}, function() end)
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