-- Load all core modules

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Setup intelligent file reload handling (auto-setup on load)
require("core.file_reload")

-- Make utility functions globally available
_G.is_windows = require("core.utils").is_windows
_G.file_exists = require("core.utils").file_exists
