-- Load all core modules

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Make utility functions globally available
_G.is_windows = require("core.utils").is_windows
_G.file_exists = require("core.utils").file_exists
