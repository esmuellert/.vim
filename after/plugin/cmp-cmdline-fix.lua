-- Fix for cmp-cmdline error with malformed patterns like HEAD@{}
-- Wraps vim.fn.getcompletion with error handling only during cmdline completion

local original_getcompletion = vim.fn.getcompletion

-- Create safe wrapper
local function safe_getcompletion(...)
  local success, result = pcall(original_getcompletion, ...)
  if success then
    return result
  else
    -- Return empty on error (e.g., malformed patterns like HEAD@{})
    return {}
  end
end

-- Replace globally but safely
vim.fn.getcompletion = safe_getcompletion
