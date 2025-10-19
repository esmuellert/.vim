-- Which-key keybinding hints

local enabled = require('config.plugins-enabled')


return {
  ------------------------------------------------------------------------
  --- 🔑 which-key.nvim: Display keybindings in a popup
  ------------------------------------------------------------------------
  {
    'folke/which-key.nvim',
    enabled = enabled.which_key,
    config = function()
      require("which-key").setup()
    end,
  },
}
