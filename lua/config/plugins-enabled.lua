-- Plugin toggle configuration
-- Set any plugin to false to disable it completely
-- This makes it easy to enable/disable plugins without commenting out code

return {
  -- Git plugins
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

  -- Diagnostics
  trouble = true,

  -- Other plugins
  eslint = true,
  xcodebuild = false,
  writing = true,
  session = true,
}
