-- Editor enhancement plugins

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  -- 💬 Comment.nvim: Efficient code commenting
  ------------------------------------------------------------------------
  {
    'numToStr/Comment.nvim',
    enabled = enabled.comment,
    event = 'BufRead',
    config = function()
      require('Comment').setup()
    end,
  },

  ------------------------------------------------------------------------
  --- 📦 nvim-autopairs: Automatically insert pairs of delimiters
  ------------------------------------------------------------------------
  {
    'windwp/nvim-autopairs',
    enabled = enabled.autopairs,
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  ------------------------------------------------------------------------
  --- 💡 vim-illuminate: Highlight matching words under cursor
  ------------------------------------------------------------------------
  {
    'RRethy/vim-illuminate',
    enabled = enabled.illuminate,
    event = 'BufRead',
  },

  ------------------------------------------------------------------------
  --- 🔍 guess-indent.nvim: Auto-detect and set indentation style
  ------------------------------------------------------------------------
  {
    'NMAC427/guess-indent.nvim',
    enabled = enabled.guess_indent,
    config = function()
      require('guess-indent').setup()
    end,
  },

  ------------------------------------------------------------------------
  --- 🔀 codediff.nvim: VSCode-style inline diff rendering
  ------------------------------------------------------------------------
  {
    'esmuellert/codediff.nvim',
    enabled = enabled.codediff,
    pin = false,
    cmd = { 'CodeDiff' },
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>df', '<cmd>CodeDiff<cr>', desc = 'Code Diff Explorer' },
      { '<leader>dh', '<cmd>CodeDiff history<CR>', desc = 'Code Diff History' },
    },
    config = function()
      local colorscheme = vim.g.colors_name or ''
      
      local config = require('codediff.config')
      local base_config = {
        explorer = {
          view_mode = 'tree',  -- Use tree view by default
        },
      }
      
      if colorscheme == 'github_light' then
        -- VSCode GitHub Light theme colors
        config.setup(vim.tbl_deep_extend('force', base_config, {
          highlights = {
            line_insert = '#d2ffd2',
            line_delete = '#ffd7d5',
            char_insert = '#acf2bd',
            char_delete = '#fdb8c0',
          },
        }))
      else
        -- Use default highlights
        config.setup(base_config)
      end
      
      -- Re-apply highlights with new config
      local render = require('codediff.render')
      render.setup_highlights()
    end,
  },
}
