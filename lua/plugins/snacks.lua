-- snacks.nvim: Collection of QoL features by Folke
-- Picker is DISABLED here — using fzf-lua instead

local enabled = require("config.plugins-enabled")

return {
  {
    "folke/snacks.nvim",
    enabled = enabled.snacks,
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- ── Features replacing standalone plugins ──────────────────────

      -- Replaces custom ToggleLazyGit() in keymaps.lua
      lazygit = { enabled = true },

      -- Replaces custom ToggleTerminal() in keymaps.lua
      terminal = { enabled = true },

      -- Replaces vim-illuminate
      words = { enabled = true },

      -- Replaces indent-blankline.nvim
      indent = {
        enabled = true,
        animate = { enabled = false },
        filter = function(buf)
          return vim.g.snacks_indent ~= false
            and vim.b[buf].snacks_indent ~= false
            and vim.bo[buf].filetype ~= ""
            and vim.bo[buf].filetype ~= "codediff-explorer"
        end,
      },

      -- Replaces large file detection in autocmds.lua
      bigfile = {
        enabled = true,
        size = 100 * 1024, -- 100KB
      },

      -- Replaces zen-mode.nvim
      zen = { enabled = true },

      -- Better vim.ui.input
      input = { enabled = true },

      -- ── Extra QoL features ─────────────────────────────────────────

      -- Delete buffers without messing up window layout
      bufdelete = { enabled = true },

      -- Smooth scrolling
      scroll = { enabled = false },

      -- Focus mode — dim inactive code
      dim = { enabled = true },

      -- Scope detection
      scope = { enabled = true },

      -- Notifications disabled (noice.nvim handles this)
      notifier = { enabled = false },

      -- Quick file open before plugins load
      quickfile = { enabled = true },

      -- Dashboard (optional — nice startup screen)
      dashboard = { enabled = false },

      -- ── Disabled (using other plugins) ─────────────────────────────
      picker = { enabled = false }, -- using fzf-lua
      explorer = { enabled = false }, -- using yazi.nvim
    },
    keys = {
      -- Terminal
      {
        "<leader>t",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle Terminal",
      },

      -- LazyGit
      {
        "<leader>g",
        function()
          Snacks.lazygit()
        end,
        desc = "LazyGit",
      },

      -- Buffer delete
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },

      -- Zen mode
      {
        "<leader>zw",
        function()
          Snacks.zen()
        end,
        desc = "Zen Mode",
      },

      -- Dim toggle
      {
        "<leader>zd",
        function()
          Snacks.dim()
        end,
        desc = "Dim Mode",
      },

      -- Words navigation (like vim-illuminate but with jumping)
      {
        "]]",
        function()
          Snacks.words.jump(1)
        end,
        desc = "Next Reference",
      },
      {
        "[[",
        function()
          Snacks.words.jump(-1)
        end,
        desc = "Prev Reference",
      },

    },
  },
}
