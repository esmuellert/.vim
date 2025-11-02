-- LazyVim plugin specs for a minimal writing setup (plain .txt)

local enabled = require('config.plugins-enabled')
-- Neovim 0.10+ recommended.



return {
  -- Distraction-free writing
  {
    "folke/zen-mode.nvim",
    enabled = enabled.zen_mode,
    ft = { "text" },
    opts = {
      window = { width = 0.62, options = { number = false, relativenumber = false, signcolumn = "no" } },
      plugins = { gitsigns = { enabled = false }, tmux = { enabled = false } },
    },
    keys = {
      { "<leader>zw", function() require("zen-mode").toggle() end, desc = "Zen: Toggle", ft = "text" },
    },
  },

  -- Prose-friendly soft wrap & paragraph motions for text
  {
    "reedes/vim-pencil",
    enabled = enabled.vim_pencil,
    ft = { "text" },
    init = function()
      vim.g["pencil#wrapModeDefault"] = "soft"  -- soft-wrap for prose
      vim.g["pencil#conceallevel"] = 0
    end,
  },

  -- Sticky notes / inline review markers like TODO:, NOTE:, etc. (works in .txt)
  {
    "folke/todo-comments.nvim",
    enabled = enabled.todo_comments,
    ft = { "text", "markdown" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      highlight = {
        multiline = true,
        multiline_pattern = "^.",
        multiline_context = 10,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = false,
        max_line_len = 400,
        exclude = {},
      },
    }
  }
}
