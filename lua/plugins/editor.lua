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
    config = function()
      require('guess-indent').setup()
    end,
  },
}
