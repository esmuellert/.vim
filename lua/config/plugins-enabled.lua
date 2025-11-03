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
  telescope = true,
  treesitter = true,
  nvim_tree = false,
  neo_tree = true,
  comment = true,
  autopairs = true,
  illuminate = true,
  guess_indent = true,
  vscode_diff = true,

  -- UI plugins
  bufferline = true,
  lualine = true,
  indent_blankline = true,
  colorizer = false,
  which_key = true,

  -- LSP and completion
  lsp = true,
  mason = true,
  cmp = true,
  lspkind = true,
  lspsaga = true,
  fidget = true,
  roslyn = true,

  -- Diagnostics
  trouble = true,

  -- Other plugins
  eslint = true,
  xcodebuild = false,
  writing = true,
  zen_mode = true,
  vim_pencil = true,
  todo_comments = true,
  session = true,
  kulala = true,
  render_markdown = true,
}
