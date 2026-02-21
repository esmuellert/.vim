-- Custom keymaps and shortcuts

-- Copy file paths to system clipboard
vim.keymap.set('n', '<leader>cp', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end, { desc = 'Copy absolute path' })
vim.keymap.set('n', '<leader>cr', function() vim.fn.setreg('+', vim.fn.expand('%')) end, { desc = 'Copy relative path' })

-- Function to diff current file with git version
local function DiffWithGit(ref)
  ref = ref or 'HEAD'

  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end

  -- Get relative path for git
  local rel_path = vim.fn.expand('%:p:~:.'):gsub('\\', '/')

  -- Save current diffopt to ensure internal diff is used
  local saved_diffopt = vim.o.diffopt

  -- Force internal diff mode (crucial for Windows to avoid E810)
  if not saved_diffopt:match('internal') then
    vim.o.diffopt = saved_diffopt .. ',internal'
  end

  -- Enable diff mode in current window
  vim.cmd('diffthis')

  -- Create vertical split on the left
  vim.cmd('leftabove vsplit')
  vim.cmd('enew')

  -- Get git version using git show
  local git_cmd = string.format('git show %s:%s', ref, rel_path)
  local git_content = vim.fn.systemlist(git_cmd)

  if vim.v.shell_error ~= 0 then
    vim.cmd('q')
    vim.cmd('wincmd l | diffoff')
    -- Restore diffopt
    vim.o.diffopt = saved_diffopt
    vim.notify('Failed to get version \'' .. ref .. '\': ' .. table.concat(git_content, '\n'), vim.log.levels.ERROR)
    return
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(0, 0, -1, false, git_content)

  -- Set buffer options (read-only)
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.bo.modifiable = false
  vim.bo.readonly = true
  vim.bo.filetype = vim.fn.getbufvar('#', '&filetype')
  vim.cmd('file ' .. ref .. ':' .. vim.fn.expand('#:t'))

  -- Enable diff in this window
  vim.cmd('diffthis')

  -- Move cursor back to the right window (current version)
  vim.cmd('wincmd l')
end

-- Create :Diff command with optional argument
vim.api.nvim_create_user_command('Diff', function(opts)
  DiffWithGit(opts.args ~= '' and opts.args or nil)
end, { nargs = '?' })

-- Lazy.nvim plugin manager
vim.keymap.set('n', '<leader>L', '<cmd>Lazy<cr>', { desc = 'Lazy Plugin Manager' })

-- Restart Neovim
vim.keymap.set('n', '<leader>R', '<cmd>restart<cr>', { desc = 'Restart Neovim' })
