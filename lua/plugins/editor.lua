-- Editor enhancement plugins

local enabled = require('config.plugins-enabled')

return {
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
      {
        '<leader>dm',
        function()
          local main = vim.fn.system('git rev-parse --verify --quiet main'):find('%S') and 'main' or 'master'
          vim.cmd('CodeDiff ' .. main .. '...')
        end,
        desc = 'Code Diff vs main/master',
      },
    },
    config = function()
      local colorscheme = vim.g.colors_name or ''
      
      local codediff = require('codediff')
      local base_config = {
        explorer = {
          view_mode = 'tree',  -- Use tree view by default
        },
      }
      
      if colorscheme == 'github_light' then
        -- VSCode GitHub Light theme colors
        codediff.setup(vim.tbl_deep_extend('force', base_config, {
          highlights = {
            line_insert = '#d2ffd2',
            line_delete = '#ffd7d5',
            char_insert = '#acf2bd',
            char_delete = '#fdb8c0',
          },
        }))
      else
        -- Use default highlights
        codediff.setup(base_config)
      end
    end,
  },
}
