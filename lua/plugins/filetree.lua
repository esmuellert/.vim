-- File tree explorer

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  --- 📂 yazi.nvim: Terminal file manager integration
  ------------------------------------------------------------------------
  {
    enabled = enabled.yazi,
    'mikavilpas/yazi.nvim',
    version = '*',
    event = 'VeryLazy',
    cond = function()
      return vim.fn.executable('yazi') == 1
    end,
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
    },
    keys = {
      { '<leader>e', '<cmd>Yazi<cr>', desc = 'Open yazi at current file' },
      { '<leader>cw', '<cmd>Yazi cwd<cr>', desc = 'Open yazi in working directory' },
      { '<c-up>', '<cmd>Yazi toggle<cr>', desc = 'Resume last yazi session' },
    },
    ---@type YaziConfig | {}
    opts = {
      open_for_directories = true,
      floating_window_scaling_factor = 0.9,
      yazi_floating_window_border = 'rounded',
      keymaps = {
        show_help = '<f1>',
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
}
