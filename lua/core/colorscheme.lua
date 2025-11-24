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
-- - github_light (if custom theme file exists)

local colorscheme = 'tokyonight-moon'

local status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not status_ok then
  vim.notify('Colorscheme ' .. colorscheme .. ' not found!', vim.log.levels.ERROR)
  return
end
