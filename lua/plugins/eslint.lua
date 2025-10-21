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
      -- Add handlers for missing LSP methods to reduce errors
      vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
        local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
        local bufnr = vim.api.nvim_get_current_buf()
        vim.diagnostic.reset(ns, bufnr)
        return vim.NIL
      end
      
      require('nvim-eslint').setup({})
    end,
  },
}
