-- Plugin toggle configuration
-- Set any plugin to false to disable it completely
-- This makes it easy to enable/disable plugins without commenting out code

local utils = require('core.utils')

return {
  -- Git plugins
  fugitive = false,
  gitsigns = true,
  diffview = true,

  -- Editor plugins
  telescope = true,
  treesitter = not utils.is_windows(),
  nvim_tree = false,
  neo_tree = true,
  comment = true,
  autopairs = true,
  illuminate = true,
  vscode_diff = true,

  -- UI plugins
  bufferline = true,
  lualine = true,
  indent_blankline = true,
  colorizer = true,
  which_key = true,

  -- LSP and completion
  lsp = true,
  mason = true,
  cmp = true,
  lspsaga = true,
  fidget = true,
  roslyn = true,

  -- Diagnostics
  trouble = true,

  -- Other plugins
  eslint = true,
  xcodebuild = false,
  writing = true,
  session = true,
  kulala = true,
  render_markdown = true,
}
