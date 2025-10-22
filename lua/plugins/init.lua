-- Plugin specifications for lazy.nvim
-- This file loads all plugin configurations from separate modules

-- Import all plugin modules
local plugin_modules = {
  require("plugins.colorscheme"),
  require("plugins.git"),
  require("plugins.telescope"),
  require("plugins.treesitter"),
  require("plugins.editor"),
  require("plugins.ui"),
  require("plugins.completion"),
  require("plugins.lsp"),
  require("plugins.roslyn"),
  require("plugins.diagnostics"),
  require("plugins.filetree"),
  require("plugins.which-key"),
  require("plugins.eslint"),
  require("plugins.xcodebuild"),
  require("plugins.writing"),
  require("plugins.session"),
}

-- Flatten the plugin list (since each module returns a table of plugins)
local plugins = {}
for _, module in ipairs(plugin_modules) do
  if type(module) == "table" then
    for _, plugin in ipairs(module) do
      table.insert(plugins, plugin)
    end
  end
end

-- Load local plugin settings if they exist
local local_plugin_path = vim.fn.stdpath('config') .. '/lua/plugin/local.lua'
if vim.loop.fs_stat(local_plugin_path) then
  local local_plugins = require("plugin.local")
  if type(local_plugins) == "table" then
    for _, plugin in ipairs(local_plugins) do
      table.insert(plugins, plugin)
    end
  end
end

return plugins
