-- octo.nvim: GitHub issues and PRs from Neovim

local enabled = require('config.plugins-enabled')

return {
  {
    'pwntester/octo.nvim',
    enabled = enabled.octo,
    cmd = 'Octo',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'ibhagwan/fzf-lua',
    },
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      default_merge_method = 'squash',
      picker = 'fzf-lua',
    },
    keys = {
      { '<leader>gi', '<cmd>Octo issue list<cr>', desc = 'List Issues (Octo)' },
      { '<leader>gI', '<cmd>Octo issue search<cr>', desc = 'Search Issues (Octo)' },
      { '<leader>gp', '<cmd>Octo pr list<cr>', desc = 'List PRs (Octo)' },
      { '<leader>gP', '<cmd>Octo pr search<cr>', desc = 'Search PRs (Octo)' },
    },
  },
}
