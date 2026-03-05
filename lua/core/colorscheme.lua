-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================
-- Set the active colorscheme here for easy switching
-- Make sure the theme plugin is installed in lua/plugins/colorscheme.lua
--
-- Available colorschemes:
-- - tokyonight-moon (default)
-- - tokyonight-storm
-- - tokyonight-night
-- - tokyonight-day
-- - catppuccin-mocha
-- - catppuccin-macchiato
-- - catppuccin-frappe
-- - catppuccin-latte
-- - kanagawa-wave
-- - kanagawa-dragon
-- - kanagawa-lotus
-- - nightfox
-- - dayfox
-- - dawnfox
-- - duskfox
-- - nordfox
-- - terafox
-- - carbonfox
-- - iceberg
-- - github_light (if custom theme file exists)

local colorscheme = "iceberg"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("Colorscheme " .. colorscheme .. " not found!", vim.log.levels.ERROR)
  return
end

-- Invisible pane borders (must be set after colorscheme)
vim.o.fillchars = vim.o.fillchars .. ",vert:│"
vim.api.nvim_set_hl(0, "WinSeparator", { link = "NonText" })
