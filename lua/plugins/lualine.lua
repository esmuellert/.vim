-- lualine.nvim: statusline

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "BufRead",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "iceberg",
          component_separators = "",
          section_separators = { left = "", right = "" },
        },
        tabline = {
          lualine_a = {
            {
              "tabs",
              mode = 2,
              max_length = vim.o.columns,
              use_mode_colors = true,
            },
          },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_c = {
            {
              "filename",
              path = 1,
            },
          },
          lualine_z = {
            { "location", separator = { right = "" }, left_padding = 2 },
          },
        },
      })
    end,
  },
}
