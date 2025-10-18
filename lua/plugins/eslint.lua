-- ESLint integration

return {
  ------------------------------------------------------------------------
  --- 🧹 nvim-eslint: Effortless ESLint integration
  ------------------------------------------------------------------------
  {
    'esmuellert/nvim-eslint',
    config = function()
      require('nvim-eslint').setup({})
    end,
  },
}
