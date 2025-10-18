-- Vim options and settings

-- Set spell check
vim.cmd('setlocal spell spelllang=en_us')

-- Set the sign column to always be visible
vim.opt.signcolumn = 'yes'

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})
