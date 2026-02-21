-- LazyDev: proper Neovim Lua API completions for lua_ls

local enabled = require('config.plugins-enabled')

return {
  {
    'folke/lazydev.nvim',
    enabled = enabled.lazydev ~= false,
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}
