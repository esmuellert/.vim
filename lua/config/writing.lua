-- Plain-text writing UX for Neovim/LazyVim
-- - Quiet buffer: no diagnostics, no completion, no pairs
-- - Soft-wrap, word-friendly line breaks, clean gutters
-- - Spell check disabled by default (toggle with <leader>ws)
-- - Optional: raw-start LTeX if present (no lspconfig)
--
-- Leader key shortcuts (active in .txt files):
-- <leader>wc  - Show word count, character count, and line count
-- <leader>ws  - Toggle spell check on/off
-- <leader>zw  - Toggle Zen mode (from zen-mode.nvim plugin)

-- Safe persistence: undo/backup
do
  local state = vim.fn.stdpath("state")
  local udir  = state .. "/undo"
  local bdir  = state .. "/backup"
  if vim.fn.isdirectory(udir) == 0 then vim.fn.mkdir(udir, "p") end
  if vim.fn.isdirectory(bdir) == 0 then vim.fn.mkdir(bdir, "p") end
  vim.opt.undofile  = true
  vim.opt.undodir   = udir
  vim.opt.backup    = true
  vim.opt.backupdir = bdir
end

-- FileType=text: apply writing view + local keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  callback = function(args)
    local bufnr = args.buf
    local o = vim.opt_local

    -- Visuals
    o.wrap         = true
    o.linebreak    = true
    o.breakindent  = false
    o.showbreak    = ""
    o.spell        = false
    o.spelllang    = "en_us"
    o.number       = false
    o.relativenumber = false
    o.signcolumn   = "no"
    o.list         = false
    o.colorcolumn  = ""
    o.cursorline   = true
    o.cmdheight    = 0
    o.fillchars    = "eob: "

    -- Behaviors
    o.textwidth    = 0
    o.formatoptions:remove({ "t" }) -- no hard-wrap by 'textwidth'
    vim.diagnostic.enable(false, { bufnr = bufnr })

    -- Keep coding plugins quiet in .txt
    pcall(function() require("cmp").setup.buffer({ enabled = false }) end)
    vim.b.minipairs_disable = true   -- for mini.pairs (LazyVim default)
    vim.b.autopairs_enabled = false  -- hint for nvim-autopairs if you use it
    vim.b.copilot_enabled = false    -- disable GitHub Copilot for text files

    -- Local keymaps
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "<leader>wc", function()
      local wc = vim.fn.wordcount()
      local msg = ("words: %d | chars: %d | lines: %d"):format(wc.words or 0, wc.chars or 0, wc.lines or 0)
      vim.notify(msg, vim.log.levels.INFO, { title = "Word Count" })
    end, "Word count")

    map("n", "<leader>ws", function()
      vim.opt_local.spell = not vim.opt_local.spell:get()
      local status = vim.opt_local.spell:get() and "enabled" or "disabled"
      vim.notify("Spell check " .. status, vim.log.levels.INFO, { title = "Spell Check" })
    end, "Toggle spell check")

    -- Visual line navigation for wrapped text
    local nav_opts = { expr = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", nav_opts)
    vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", nav_opts)
    vim.keymap.set("v", "j", "v:count == 0 ? 'gj' : 'j'", nav_opts)
    vim.keymap.set("v", "k", "v:count == 0 ? 'gk' : 'k'", nav_opts)
  end,
})
