-- Plugin toggle configuration
-- Set any plugin to false to disable it completely
-- This makes it easy to enable/disable plugins without commenting out code

local utils = require('core.utils')

return {
  -- Git plugins
  fugitive = true,
  gitsigns = true,
  diffview = true,

  -- Editor plugins
  telescope = false,
  treesitter = true,
  nvim_tree = false,
  neo_tree = false,
  yazi = true,
  autopairs = true,
  illuminate = false,
  guess_indent = true,
  codediff = true,

  -- UI plugins
  bufferline = true,
  lualine = true,
  indent_blankline = false,
  colorizer = false,
  which_key = true,

  -- LSP and completion
  lsp = true,
  mason = true,
  cmp = false,
  lspkind = false,
  blink_cmp = true,
  fidget = true,
  roslyn = true,

  -- Diagnostics
  trouble = true,

  -- Other plugins
  eslint = true,
  xcodebuild = false,
  writing = true,
  zen_mode = false,
  vim_pencil = true,
  todo_comments = true,
  session = true,
  kulala = true,
  render_markdown = true,

  -- New plugins (toggle to try)
  fzf_lua = true,
  snacks_picker = false,
  snacks = true,
  conform = true,
  noice = true,
}
