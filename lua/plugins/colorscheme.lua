-- Colorschemes. iceberg is the default; catppuccin and tokyonight are also
-- installed. Switch live with <leader>uc (see lua/config/theme.lua), which
-- persists your choice across restarts.

return {
  {
    "cocopon/iceberg.vim",
    lazy = false,
    priority = 1000,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { light = "latte", dark = "mocha" },
      })
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "storm" }, -- storm, moon, night, day
  },
}
