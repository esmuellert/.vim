-- Session management plugin

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  -- 💾 persistence.nvim: Simple session management
  ------------------------------------------------------------------------
  {
    'folke/persistence.nvim',
    enabled = enabled.session,
    event = 'VimEnter',
    opts = {
      dir = vim.fn.stdpath('state') .. '/sessions/', -- directory where session files are saved
      -- Remove 'blank' from sessionoptions to avoid saving special buffers like diffview
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' },
      pre_save = nil,
      save_empty = false, -- don't save if there are no open file buffers
    },
    config = function(_, opts)
      require('persistence').setup(opts)
      
      -- Close diffview before saving session
      vim.api.nvim_create_autocmd('User', {
        pattern = 'PersistenceSavePre',
        group = vim.api.nvim_create_augroup('persistence_diffview_cleanup', { clear = true }),
        callback = function()
          -- Close diffview if it's open
          pcall(function()
            local diffview_lib = require('diffview.lib')
            local views = diffview_lib.views
            if views and next(views) ~= nil then
              vim.cmd('DiffviewClose')
              -- Give it a moment to close properly
              vim.wait(100)
            end
          end)
        end,
      })
      
      -- Auto-restore session when opening nvim without arguments
      vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('persistence_auto_restore', { clear = true }),
        callback = function()
          -- Only load the session if nvim was started with no args
          if vim.fn.argc() == 0 then
            require('persistence').load()
          end
        end,
        nested = true,
      })
    end,
    keys = {
      {
        '<leader>qs',
        function()
          require('persistence').load()
        end,
        desc = 'Restore Session',
      },
      {
        '<leader>ql',
        function()
          require('persistence').load({ last = true })
        end,
        desc = 'Restore Last Session',
      },
      {
        '<leader>qd',
        function()
          require('persistence').stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
}
