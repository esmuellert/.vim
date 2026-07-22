-- Which-key keybinding hints

return {
  ------------------------------------------------------------------------
  --- 🔑 which-key.nvim: Display keybindings in a popup
  ------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },
}
