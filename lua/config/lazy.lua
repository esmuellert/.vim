-- Bootstrap lazy.nvim and load all plugins from lua/plugins/

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Auto-import every spec file under lua/plugins/ (presence = enabled)
  spec = { { import = "plugins" } },
  defaults = { lazy = false, version = false },
  install = { missing = true },
  dev = { path = "~", fallback = true },
  checker = { enabled = false },
  change_detection = { enabled = false, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Colorscheme (after plugins so the theme is installed); restores last pick
require("config.theme").load()
vim.o.fillchars = vim.o.fillchars .. ",vert:│"
vim.api.nvim_set_hl(0, "WinSeparator", { link = "NonText" })

-- Machine-specific settings (optional, gitignored)
if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/local.lua") then
  require("local")
end
