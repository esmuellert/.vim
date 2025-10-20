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

