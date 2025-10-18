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

------------------------------------------------------------------------
--- Auto-reload files changed outside of Neovim
------------------------------------------------------------------------
vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI'}, {
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
  desc = "Check if buffers changed outside of Neovim"
})

------------------------------------------------------------------------
--- Diagnostic line highlighting setup
------------------------------------------------------------------------
-- Setup diagnostic line highlights with only background color from theme
local function setup_diagnostic_line_highlights()
  -- Get colors from DiagnosticVirtualText highlights
  local error_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticVirtualTextError" })
  local warn_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticVirtualTextWarn" })
  local hint_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticVirtualTextHint" })
  local info_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticVirtualTextInfo" })

  -- Set line highlights with only background color (preserving text color)
  vim.api.nvim_set_hl(0, "DiagnosticLineError", { bg = error_hl.bg })
  vim.api.nvim_set_hl(0, "DiagnosticLineWarn", { bg = warn_hl.bg })
  vim.api.nvim_set_hl(0, "DiagnosticLineHint", { bg = hint_hl.bg })
  vim.api.nvim_set_hl(0, "DiagnosticLineInfo", { bg = info_hl.bg })

  -- Set underline highlights with diagnostic color
  -- Use sp for undercurl color and nocombine to prevent fg from being combined
  -- Note: colored undercurls require terminal support (termguicolors + undercurl color support)
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
    undercurl = true,
    sp = error_hl.fg,
    nocombine = true
  })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
    undercurl = true,
    sp = warn_hl.fg,
    nocombine = true
  })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
    undercurl = true,
    sp = hint_hl.fg,
    nocombine = true
  })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
    undercurl = true,
    sp = info_hl.fg,
    nocombine = true
  })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_diagnostic_line_highlights,
  desc = "Setup diagnostic line highlighting for all colorschemes"
})

-- Apply immediately for current colorscheme with delay
vim.defer_fn(setup_diagnostic_line_highlights, 200)

