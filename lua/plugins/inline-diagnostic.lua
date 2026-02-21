-- tiny-inline-diagnostic: better inline diagnostic display

local enabled = require('config.plugins-enabled')

return {
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    enabled = enabled.tiny_diagnostic ~= false,
    event = 'LspAttach',
    priority = 1000,
    config = function()
      -- Disable default virtual text (tiny-inline-diagnostic replaces it)
      vim.diagnostic.config({ virtual_text = false })
      require('tiny-inline-diagnostic').setup({
        preset = 'modern',
      })
    end,
  },
}
