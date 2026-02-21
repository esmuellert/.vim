-- inc-rename: live incremental rename preview

local enabled = require('config.plugins-enabled')

return {
  {
    'smjonas/inc-rename.nvim',
    enabled = enabled.inc_rename ~= false,
    cmd = 'IncRename',
    opts = {},
  },
}
