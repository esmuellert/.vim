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

-- ============================================================================
-- Performance Settings - Prevent "redrawtime exceeded" errors
-- ============================================================================
-- Increase redrawtime to prevent syntax highlighting timeouts
-- Default is 2000ms which is too low for large files with treesitter
vim.opt.redrawtime = 10000 -- 10 seconds (prevents timeout on large/complex files)

-- Increase pattern matching memory for complex syntax
vim.opt.maxmempattern = 5000 -- Default is 1000

-- Set a reasonable timeout for mapping delays
vim.opt.timeoutlen = 500 -- Faster than default 1000ms

-- Update time for better responsiveness (also affects swap file writing)
vim.opt.updatetime = 250 -- Default is 4000ms

-- Sync time for file change detection
vim.opt.synmaxcol = 500 -- Don't highlight lines longer than 500 chars (prevents slowdown)

-- ============================================================================

-- Diagnostic configuration
-- Global: Show Error, Warning, and Info (but not Hint)
-- Roslyn-specific override in plugins/roslyn.lua to only show Error and Warning
vim.diagnostic.config({
  virtual_text = {
    prefix = '',
    severity = { min = vim.diagnostic.severity.INFO }, -- Show INFO and above globally
  },
  severity_sort = true,
  underline = {
    severity = { min = vim.diagnostic.severity.INFO }, -- Show INFO and above globally
  },
  signs = {
    severity = { min = vim.diagnostic.severity.INFO }, -- Show INFO and above globally
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticLineError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticLineWarn',
      [vim.diagnostic.severity.HINT] = 'DiagnosticLineHint',
      [vim.diagnostic.severity.INFO] = 'DiagnosticLineInfo',
    },
  },
})

-- Diff mode improvements
-- Add diagonal lines for deleted lines in diff mode (makes diffs clearer)
vim.opt.fillchars:append({
  diff = '╱', -- Diagonal lines for deleted sections
  fold = ' ',
  eob = ' ', -- Suppress ~ on empty lines
})

-- Diff options - IMPORTANT: 'internal' is crucial for Windows to avoid E810 errors
local diffopt = {
  'internal', -- Use internal xdiff library (required for Windows)
  'filler', -- Show filler lines for deleted/added lines
  'closeoff', -- Turn off diff when closing window
  'vertical', -- Use vertical splits by default
  'algorithm:histogram', -- Algorithm: myers (default/fast), minimal (thorough/slow), patience (readable), histogram (balanced)
  'indent-heuristic', -- Slide diffs along indentation for better alignment
  -- 'linematch:60', -- Match similar lines within diff blocks (max 60 lines)
  -- 'iwhite',
  'inline:char'
}

-- Add inline word-level diffs for Neovim 0.12+
if vim.fn.has('nvim-0.12') == 1 then
  table.insert(diffopt, 'inline:word')
end

vim.opt.diffopt = diffopt

-- Auto-reload files when changed outside of Neovim
vim.o.autoread = true
