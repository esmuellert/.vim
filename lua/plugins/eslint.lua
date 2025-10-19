-- ESLint integration

local enabled = require('config.plugins-enabled')


return {
  ------------------------------------------------------------------------
  --- 🧹 nvim-eslint: Effortless ESLint integration
  ------------------------------------------------------------------------
  {
    'esmuellert/nvim-eslint',
    enabled = enabled.eslint,
    config = function()
      require('nvim-eslint').setup({})
    end,
  },
}
