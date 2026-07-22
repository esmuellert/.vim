-- ============================================================================
-- Neovim configuration entry point
-- ============================================================================
--   lua/config/   - options, keymaps, autocmds, lazy bootstrap
--   lua/plugins/  - one plugin spec per file, auto-imported by lazy.nvim
-- ============================================================================

-- Leader keys must be set before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
