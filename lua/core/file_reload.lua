-- ============================================================================
-- Simple File Reload - Minimal & Fast
-- ============================================================================
-- Auto-reload files changed externally (only if no unsaved changes)
-- Skips build output folders to prevent freeze during dotnet build
-- ============================================================================

local M = {}

-- Auto-reload handler
local function on_file_changed_shell()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- Skip build output folders
  if filename:match('[/\\]obj[/\\]') or filename:match('[/\\]bin[/\\]') then
    return
  end

  -- Only reload if no unsaved changes
  if not vim.bo[bufnr].modified then
    vim.cmd('checktime')
  else
    -- Notify user about conflict
    vim.schedule(function()
      vim.notify(
        string.format('File "%s" changed externally but you have unsaved changes', 
          vim.fn.fnamemodify(filename, ':t')),
        vim.log.levels.WARN
      )
    end)
  end
end

-- Setup autocmds
local function setup()
  local group = vim.api.nvim_create_augroup('SimpleFileReload', { clear = true })

  vim.api.nvim_create_autocmd('FileChangedShell', {
    group = group,
    callback = on_file_changed_shell,
    desc = "Handle external file changes"
  })

  -- Enable auto-reload
  vim.o.autoread = true
end

-- Auto-setup on module load
setup()

return M
