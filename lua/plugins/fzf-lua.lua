-- fzf-lua fuzzy finder
--
-- Alternative to telescope with native fzf performance.
-- Uses fzf binary directly for blazing-fast fuzzy matching.

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  -- 🔍 fzf-lua: Improved fzf.vim written in lua
  ------------------------------------------------------------------------
  {
    'ibhagwan/fzf-lua',
    enabled = enabled.fzf_lua,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    cmd = 'FzfLua',
    keys = {
      { '<leader>p', '<cmd>FzfLua files<cr>', desc = 'Find files' },
      { '<leader>f', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
      { '<leader>b', '<cmd>FzfLua buffers<cr>', desc = 'Buffers' },
      { '<leader>hp', '<cmd>FzfLua helptags<cr>', desc = 'Help tags' },
      { '<leader>d', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Diagnostics' },
      { '<leader>hl', '<cmd>FzfLua highlights<cr>', desc = 'Highlights' },
      { '<leader>/', '<cmd>FzfLua blines<cr>', desc = 'Fuzzy find in buffer' },
      { '<leader>r', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent files' },
      { '<leader>fr', '<cmd>FzfLua resume<cr>', desc = 'Resume last picker' },
    },
    config = function()
      local actions = require('fzf-lua.actions')

      require('fzf-lua').setup({
        -- Global options
        winopts = {
          height = 0.80,
          width = 0.87,
          row = 0.35,
          col = 0.50,
          border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
          preview = {
            layout = 'horizontal',
            horizontal = 'right:55%',
            scrollbar = 'float',
            delay = 60,
          },
        },

        -- Prompt and selection indicators
        fzf_opts = {
          ['--layout'] = 'reverse',
          ['--info'] = 'inline-right',
          ['--pointer'] = '❯',
          ['--marker'] = '✓',
        },

        -- Global keymaps inside fzf window
        keymap = {
          builtin = {
            ['<C-/>'] = 'toggle-help',
            ['<C-u>'] = 'preview-page-up',
            ['<C-d>'] = 'preview-page-down',
          },
          fzf = {
            ['ctrl-q'] = 'select-all+accept',
            ['ctrl-u'] = 'preview-page-up',
            ['ctrl-d'] = 'preview-page-down',
          },
        },

        -- Default actions for all pickers
        actions = {
          files = {
            ['default'] = actions.file_edit_or_qf,
            ['ctrl-s'] = actions.file_vsplit,
            ['ctrl-x'] = actions.file_split,
            ['ctrl-t'] = actions.file_tabedit,
            ['ctrl-q'] = actions.file_sel_to_qf,
          },
        },

        -- File finder (mirrors telescope find_files)
        files = {
          prompt = '🔍 ',
          cmd = vim.fn.executable('fd') == 1
            and 'fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .npm --exclude .cache --exclude .vscode --exclude .idea --exclude __pycache__'
            or 'rg --files --hidden --glob !**/.git/* --glob !**/node_modules/* --glob !**/.npm/* --glob !**/.cache/* --glob !**/.vscode/* --glob !**/.idea/* --glob !**/__pycache__/*',
          file_icons = true,
          git_icons = true,
          cwd_prompt = false,
        },

        -- Live grep (mirrors telescope live_grep with smart case + hidden)
        grep = {
          prompt = '🔭 ',
          rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden --glob=!**/.git/* --glob=!**/node_modules/* --glob=!**/.npm/* --glob=!**/.cache/*',
          no_header = false,
          no_header_i = false,
        },

        -- Buffers picker (mirrors telescope buffers)
        buffers = {
          prompt = '📋 ',
          sort_lastused = true,
          ignore_current_buffer = true,
          no_term_buffers = true,
          fzf_opts = { ['--layout'] = 'reverse' },
          actions = {
            ['ctrl-d'] = { fn = actions.buf_del, reload = true },
          },
        },

        -- Old files / recent files
        oldfiles = {
          prompt = '📂 ',
          cwd_only = true,
          include_current_session = true,
        },

        -- Buffer lines (fuzzy find in current buffer)
        blines = {
          prompt = '🔎 ',
          no_term_buffers = true,
        },

        -- Diagnostics
        diagnostics = {
          prompt = '⚠️  ',
        },

        -- Help tags
        helptags = {
          prompt = '📖 ',
        },

        -- Highlights
        highlights = {
          prompt = '🎨 ',
        },

        -- Git status (fzf-lua specific nice feature)
        git = {
          status = {
            prompt = ' ',
          },
        },
      })
    end,
  },
}
