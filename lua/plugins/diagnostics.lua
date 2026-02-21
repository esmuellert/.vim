-- Diagnostics and trouble shooting

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  --- 🚨 Trouble.nvim: Pretty list for diagnostics
  ------------------------------------------------------------------------
  {
    'folke/trouble.nvim',
    enabled = enabled.trouble,
    cmd = { 'Trouble' },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
      -- Keep old keymap for compatibility
      { '<leader>tb', '<cmd>Trouble diagnostics toggle <cr>', desc = 'Trouble diagnostics' },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup()
    end,
  },
}
