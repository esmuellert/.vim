-- Load all core modules

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Setup intelligent file reload handling
require("core.file_reload").setup({
  -- notify_on_reload = true,  -- Show notification when file reloads
  -- notify_timeout = 3000,     -- Notification duration in ms
  -- auto_reload_if_unchanged = true,  -- Auto-reload if no unsaved changes
  -- backup_if_changed = true,  -- Backup unsaved changes before external reload
})

-- Make utility functions globally available
_G.is_windows = require("core.utils").is_windows
_G.file_exists = require("core.utils").file_exists
