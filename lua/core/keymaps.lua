-- Custom keymaps and shortcuts

--- Prettier format current buffer
vim.api.nvim_set_keymap('n', '<A-S-F>', ':w!<CR> :!pnpm exec prettier --write %<CR> :edit!<CR>',
  { noremap = true, silent = true })

-- Function to toggle terminal buffer
function ToggleTerminal()
  -- Find the terminal buffer
  local term_buf = vim.fn.bufnr('term://*')

  if term_buf ~= -1 then
    -- Get the window number where the terminal buffer is displayed
    local term_win = vim.fn.bufwinnr(term_buf)

    if term_win ~= -1 then
      -- If the terminal is visible, hide the tab (close the tab)
      vim.cmd('tabclose')
    else
      -- If the terminal exists but is not visible, switch to it in a new tab
      vim.cmd('tabnew | buffer ' .. term_buf)
    end
  else
    -- If no terminal exists, open a new terminal in a new tab
    vim.cmd('tabnew | terminal')
    -- Automatically enter insert mode and hide line numbers
    vim.cmd('startinsert')
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
end

-- Map <leader>t to toggle terminal
vim.api.nvim_set_keymap('n', '<leader>t', ':lua ToggleTerminal()<CR>', { noremap = true, silent = true })

-- Function to toggle LazyGit
function ToggleLazyGit()
  -- Find the terminal buffer running LazyGit
  local term_buf = vim.fn.bufnr('term://*lazygit')

  if term_buf ~= -1 then
    -- Get the window number of the terminal buffer
    local term_win = vim.fn.bufwinnr(term_buf)

    if term_win ~= -1 then
      -- If the terminal is visible, switch to its tab
      vim.cmd('tabnew | buffer ' .. term_buf)
      vim.cmd('startinsert')
    else
      -- If the terminal exists but isn't visible, open it in a new tab
      vim.cmd('tabnew | buffer ' .. term_buf)
      vim.cmd('startinsert')
    end
  else
    -- If LazyGit is not running, check if it's installed
    if vim.fn.executable('lazygit') == 1 then
      -- Open LazyGit in a new tab
      vim.cmd('tabnew | terminal lazygit')
      vim.cmd('startinsert')

      -- Hide line numbers for the terminal window
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false

      -- Automatically exit insert mode when LazyGit closes
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = 0, -- Current buffer
        callback = function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        end,
      })
    else
      print("LazyGit is not installed or not found in PATH.")
    end
  end
end

-- Map <leader>g to toggle LazyGit
vim.api.nvim_set_keymap('n', '<leader>g', ':lua ToggleLazyGit()<CR>', { noremap = true, silent = true })

-- Copy file paths to system clipboard
vim.api.nvim_set_keymap('n', '<leader>cp', ':let @+ = expand("%:p")<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cr', ':let @+ = expand("%")<CR>', { noremap = true, silent = true })

-- Reload Neovim configuration
vim.api.nvim_set_keymap('n', '<leader>R', ':lua ReloadConfig()<CR>', { noremap = true, silent = false })

-- Function to reload config and preserve colorscheme
function ReloadConfig()
  -- Save current colorscheme (set by :colorscheme command)
  local current_colorscheme = vim.g.colors_name

  -- Reload config
  vim.cmd('source $MYVIMRC')

  -- Restore colorscheme after a short delay to let plugins reload
  vim.defer_fn(function()
    if current_colorscheme and current_colorscheme ~= "" then
      pcall(function() vim.cmd('colorscheme ' .. current_colorscheme) end)
      vim.notify("Config reloaded! Theme: " .. current_colorscheme, vim.log.levels.INFO)
    else
      vim.notify("Config reloaded!", vim.log.levels.INFO)
    end
  end, 100)
end

-- Function to diff current file with git version
function DiffWithGit(ref)
  ref = ref or 'HEAD'

  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
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
    vim.notify("Failed to get version '" .. ref .. "': " .. table.concat(git_content, '\n'), vim.log.levels.ERROR)
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

