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

-- Diff mode improvements
-- Add diagonal lines for deleted lines in diff mode (makes diffs clearer)
vim.opt.fillchars:append({
  diff = "╱",  -- Diagonal lines for deleted sections
  fold = " ",
  eob = " ",  -- Suppress ~ on empty lines
})

-- Auto-reload files when changed outside of Neovim
vim.o.autoread = true
