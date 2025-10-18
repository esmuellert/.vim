-- Autocommands

------------------------------------------------------------------------
--- Workaround for Neovim 0.12-dev treesitter bug
------------------------------------------------------------------------
-- Disable treesitter for vim/lua files due to parser/query version mismatch
-- Issue: Query error "Invalid node type 'substitute'" in system vim queries

-- Disable on FileType event
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vim", "lua" },
  callback = function(args)
    -- Stop treesitter highlighting for this buffer
    pcall(vim.treesitter.stop, args.buf)
  end,
  desc = "Disable treesitter highlighting for vim/lua files (Neovim 0.12 compatibility)"
})

-- Also disable on BufEnter to catch telescope previews
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.vim", "*.lua" },
  callback = function(args)
    -- Check if buffer has vim or lua filetype
    local ft = vim.bo[args.buf].filetype
    if ft == "vim" or ft == "lua" then
      pcall(vim.treesitter.stop, args.buf)
    end
  end,
  desc = "Disable treesitter for vim/lua buffers (Neovim 0.12 compatibility)"
})
