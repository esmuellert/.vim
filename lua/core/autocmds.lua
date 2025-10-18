-- Autocommands

------------------------------------------------------------------------
--- Workaround for Neovim 0.12-dev treesitter bug
------------------------------------------------------------------------
-- Disable treesitter for vim/lua files due to parser/query version mismatch
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vim", "lua" },
  callback = function()
    vim.treesitter.stop()
  end,
})
