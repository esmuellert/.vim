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
  --- 🔀 vscode-diff.nvim: VSCode-style inline diff rendering
  ------------------------------------------------------------------------
  {
    'esmuellert/vscode-diff.nvim',
    enabled = enabled.vscode_diff,
    pin = false,
    cmd = { 'CodeDiff' },
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>df', '<cmd>CodeDiff<cr>', desc = 'Code Diff Explorer' },
      { '<leader>dh', '<cmd>CodeDiff file HEAD<CR>', desc = 'Diff current file with HEAD' },
    },
    config = function()
      require('vscode-diff.config').setup({})
    end,
  },
}
