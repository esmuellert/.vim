-- render-markdown.nvim: render markdown in-buffer

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      -- Ignore codediff virtual buffers to avoid treesitter errors
      ignore = function(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        return name:match("^vscodediff://") ~= nil
      end,
    },
  },
}
