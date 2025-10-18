-- Core utility functions

local M = {}

--- Check if the current OS is Windows
function M.is_windows()
  return vim.loop.os_uname().sysname == 'Windows_NT'
end

--- Check if path exists
function M.file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

return M
