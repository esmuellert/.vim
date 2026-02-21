-- Formatting with conform.nvim

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  --- 🎨 conform.nvim: Lightweight formatter plugin
  ------------------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    enabled = enabled.conform,
    event = 'BufWritePre',
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>fm',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        desc = 'Format buffer',
      },
    },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
          typescript = { 'prettierd', 'prettier', stop_after_first = true },
          javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          css = { 'prettierd', 'prettier', stop_after_first = true },
          html = { 'prettierd', 'prettier', stop_after_first = true },
          json = { 'prettierd', 'prettier', stop_after_first = true },
          markdown = { 'prettierd', 'prettier', stop_after_first = true },
          lua = { 'stylua' },
          c = { 'clang-format' },
          cpp = { 'clang-format' },
          python = { 'ruff_format', 'black', stop_after_first = true },
          cs = { 'csharpier' },
        },
        default_format_opts = {
          lsp_format = 'fallback',
        },
        format_on_save = function(bufnr)
          -- Respect a buffer-local or global disable flag
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_format = 'fallback' }
        end,
      })
    end,
  },
}
