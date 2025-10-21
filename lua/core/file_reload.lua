-- ============================================================================
-- Intelligent File Reload & External Change Handling
-- ============================================================================
-- This module provides smart handling of external file changes:
-- - Auto-reload if no unsaved changes
-- - Backup unsaved changes before reload if file changed externally
-- - Notifications and comparison tools
-- ============================================================================

local M = {}

-- Configuration
local config = {
  backup_dir = vim.fn.stdpath('data') .. '/external_change_backups',
  notify_on_reload = true,
  notify_timeout = 3000,
  auto_reload_if_unchanged = true,
  backup_if_changed = true,
}

-- Ensure backup directory exists
local function ensure_backup_dir()
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(config.backup_dir)
  if not stat then
    vim.fn.mkdir(config.backup_dir, 'p')
  end
end

-- Ensure undo directory exists
local function ensure_undo_dir()
  local undo_dir = vim.fn.stdpath('data') .. '/undo'
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(undo_dir)
  if not stat then
    vim.fn.mkdir(undo_dir, 'p')
  end
end

-- Ensure swap directory exists (if using swap files)
local function ensure_swap_dir()
  local swap_dir = vim.fn.stdpath('data') .. '/swap'
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(swap_dir)
  if not stat then
    vim.fn.mkdir(swap_dir, 'p')
  end
end

-- Setup directories on module load
local function setup_directories()
  ensure_backup_dir()
  ensure_undo_dir()
  -- Only create swap dir if swap files are enabled
  if vim.o.swapfile then
    ensure_swap_dir()
  end
end

-- Handle external file changes BEFORE reload
-- This is where we backup unsaved changes
local function on_file_changed_shell()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- Only handle real files
  if filename == '' then
    return
  end
  
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(filename)
  if not stat then
    return
  end

  -- Temporarily detach gitsigns to prevent race conditions during reload
  local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
  if has_gitsigns then
    pcall(gitsigns.detach, bufnr)
  end

  -- Check if buffer has unsaved changes
  if vim.bo[bufnr].modified and config.backup_if_changed then
    -- Generate backup filename with timestamp
    local backup_name = string.format('%s/%s.backup.%s',
      config.backup_dir,
      vim.fs.basename(filename),
      os.date('%Y%m%d_%H%M%S')
    )

    -- Save current buffer content to backup
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local ok, err = pcall(vim.fn.writefile, lines, backup_name)

    if ok then
      vim.schedule(function()
        vim.notify(
          string.format(
            '⚠️  File changed externally with unsaved changes!\n\n' ..
            'Your unsaved changes saved to:\n%s\n\n' ..
            'External changes will be loaded.\n' ..
            'Use :CompareBackup to review your changes.',
            vim.fn.fnamemodify(backup_name, ':~')
          ),
          vim.log.levels.WARN,
          {
            title = 'External File Change',
            timeout = config.notify_timeout * 2  -- Longer timeout for warnings
          }
        )
      end)

      -- Clear modified flag so Neovim will auto-reload
      -- This allows the external changes to load
      vim.bo[bufnr].modified = false
    else
      vim.schedule(function()
        vim.notify(
          string.format('Failed to backup unsaved changes: %s', err),
          vim.log.levels.ERROR
        )
      end)
    end
  end

  -- If no unsaved changes, silent reload will happen automatically
  -- due to autoread setting
end

-- Handle notification AFTER file has been reloaded
local function on_file_changed_shell_post()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- Re-attach gitsigns after reload
  vim.defer_fn(function()
    local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
    if has_gitsigns and vim.api.nvim_buf_is_valid(bufnr) then
      pcall(gitsigns.attach, bufnr)
    end
  end, 100)  -- Small delay to ensure file is fully reloaded

  if not config.notify_on_reload then
    return
  end

  if filename ~= '' then
    vim.schedule(function()
      vim.notify(
        string.format('✓ File reloaded: %s', vim.fs.basename(filename)),
        vim.log.levels.INFO,
        {
          title = 'External Change',
          timeout = config.notify_timeout
        }
      )
    end)
  end
end

-- Setup autocmds
local function setup_autocmds()
  local group = vim.api.nvim_create_augroup('IntelligentFileReload', { clear = true })

  -- Before reload - backup unsaved changes if needed
  vim.api.nvim_create_autocmd('FileChangedShell', {
    group = group,
    callback = on_file_changed_shell,
    desc = "Backup unsaved changes before external reload"
  })

  -- After reload - notify user
  vim.api.nvim_create_autocmd('FileChangedShellPost', {
    group = group,
    callback = on_file_changed_shell_post,
    desc = "Notify after file reloaded from external change"
  })
end

-- Command to compare current file with most recent backup
local function compare_with_backup()
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == '' then
    vim.notify('Current buffer is not a file', vim.log.levels.WARN)
    return
  end

  local current_basename = vim.fs.basename(current_file)
  local pattern = string.format('%s/%s.backup.*', config.backup_dir, current_basename)
  local backup_files = vim.fn.glob(pattern, false, true)

  if #backup_files == 0 then
    vim.notify(
      string.format('No backup files found for %s', current_basename),
      vim.log.levels.WARN
    )
    return
  end

  -- Sort backups by name (timestamp in name), most recent first
  table.sort(backup_files, function(a, b) return a > b end)
  local most_recent = backup_files[1]

  -- Open in vertical split and start diff
  vim.cmd.vsplit(vim.fn.fnameescape(most_recent))
  vim.cmd.diffthis()
  vim.cmd.wincmd('p')
  vim.cmd.diffthis()

  vim.notify(
    string.format('Comparing with backup from %s',
      vim.fs.basename(most_recent):match('%.backup%.(.+)$') or 'unknown'
    ),
    vim.log.levels.INFO
  )
end

-- Command to list all backups
local function list_backups()
  local backup_files = vim.fn.glob(config.backup_dir .. '/*.backup.*', false, true)

  if #backup_files == 0 then
    vim.notify('No backup files found', vim.log.levels.INFO)
    return
  end

  -- Sort by timestamp (newest first)
  table.sort(backup_files, function(a, b) return a > b end)

  -- Display in a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'

  local lines = { '# External Change Backups', '' }
  for _, backup in ipairs(backup_files) do
    local basename = vim.fs.basename(backup)
    local file_part = basename:match('(.+)%.backup%.')
    local time_part = basename:match('%.backup%.(.+)$')
    table.insert(lines, string.format('- %s (from %s)', file_part, time_part))
    table.insert(lines, string.format('  %s', backup))
    table.insert(lines, '')
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- Open in split
  vim.cmd.split()
  vim.api.nvim_win_set_buf(0, buf)
end

-- Command to clean old backups
local function clean_backups(days)
  days = days or 7  -- Default: keep last 7 days
  local cutoff_time = os.time() - (days * 24 * 60 * 60)

  local backup_files = vim.fn.glob(config.backup_dir .. '/*.backup.*', false, true)
  local deleted = 0

  for _, backup in ipairs(backup_files) do
    local mtime = vim.fn.getftime(backup)
    if mtime > 0 and mtime < cutoff_time then
      vim.fn.delete(backup)
      deleted = deleted + 1
    end
  end

  vim.notify(
    string.format('Deleted %d backup(s) older than %d days', deleted, days),
    vim.log.levels.INFO
  )
end

-- Setup user commands
local function setup_commands()
  vim.api.nvim_create_user_command('CompareBackup', compare_with_backup, {
    desc = 'Compare current file with most recent backup'
  })

  vim.api.nvim_create_user_command('ListBackups', list_backups, {
    desc = 'List all external change backups'
  })

  vim.api.nvim_create_user_command('CleanBackups', function(opts)
    local days = tonumber(opts.args) or 7
    clean_backups(days)
  end, {
    desc = 'Clean backups older than N days (default: 7)',
    nargs = '?'
  })
end

-- Setup function to be called from init.lua
function M.setup(user_config)
  -- Merge user config with defaults
  if user_config then
    config = vim.tbl_deep_extend('force', config, user_config)
  end

  -- Setup directories
  setup_directories()

  -- Configure Neovim options for smart reload
  vim.o.autoread = true  -- Enable auto-reload
  vim.opt.undofile = true  -- Persistent undo
  vim.opt.undodir = vim.fn.stdpath('data') .. '/undo//'

  -- Optional: disable swap files (rely on undo instead)
  -- Uncomment if you want to eliminate swap file warnings entirely
  -- vim.opt.swapfile = false

  -- If keeping swap files, centralize them
  if vim.o.swapfile then
    vim.opt.directory = vim.fn.stdpath('data') .. '/swap//'
  end

  -- Setup autocmds and commands
  setup_autocmds()
  setup_commands()
end

return M
