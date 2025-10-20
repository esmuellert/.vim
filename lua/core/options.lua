-- Vim options and settings

-- Enable true color support
vim.opt.termguicolors = true

-- Set spell check
vim.cmd('setlocal spell spelllang=en_us')

-- Set the sign column to always be visible
vim.opt.signcolumn = 'yes'

-- Enable responsive mouse interactions (needed for hover-driven UIs)
vim.opt.mousemoveevent = true

-- Hint that the terminal can keep up with rapid screen updates
vim.opt.ttyfast = true

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = "",
  },
  severity_sort = true,
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticLineError",
      [vim.diagnostic.severity.WARN] = "DiagnosticLineWarn",
      [vim.diagnostic.severity.HINT] = "DiagnosticLineHint",
      [vim.diagnostic.severity.INFO] = "DiagnosticLineInfo",
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
