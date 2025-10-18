-- ============================================================================
-- Neovim Configuration Entry Point
-- ============================================================================
-- This is the main init.lua for Neovim
-- Configuration is organized into modular files for easy maintenance
--
-- Structure:
--   lua/core/           - Core settings, keymaps, autocmds, utilities
--   lua/plugins/        - Plugin configurations (one file per category)
--   lua/themes/         - Custom color themes
--   lua/config/         - Additional configurations (like writing.lua)
--   vimrc              - Legacy vim configuration (only loaded in vim, not nvim)
-- ============================================================================

-- Source the legacy vimrc (wrapped in `if !has('nvim')` so only for vim)
local vimrc_path = vim.fn.stdpath('config') .. '/vimrc'
if vim.loop.fs_stat(vimrc_path) then
  vim.cmd('source ' .. vimrc_path)
end

-- Load core configuration
require("core")

-- ============================================================================
-- 💤 Lazy.nvim Plugin Manager Setup
-- ============================================================================
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load plugins from lua/plugins/init.lua (which loads all plugin modules)
require("lazy").setup("plugins", {
  -- Lazy.nvim configuration options
  defaults = {
    lazy = false, -- plugins are not lazy-loaded by default
    version = false, -- don't use versions by default
  },
  install = {
    missing = true, -- install missing plugins on startup
    colorscheme = { "github_light" },
  },
  checker = {
    enabled = false, -- don't check for plugin updates automatically
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ============================================================================
-- Load additional configurations
-- ============================================================================
-- Load writing configuration if it exists
local writing_config_path = vim.fn.stdpath("config") .. "/lua/config/writing.lua"
if vim.loop.fs_stat(writing_config_path) then
  require("config.writing")
end

-- Load local user configuration if it exists (for machine-specific settings)
local local_config_path = vim.fn.stdpath("config") .. "/lua/local.lua"
if vim.loop.fs_stat(local_config_path) then
  require("local")
end
