-- lua_ls: Lua language server
-- Requires: lua-language-server in PATH

local lsp_helpers = require('core.lsp-helpers')

local lua_ls_binary = vim.fn.exepath('lua-language-server')

if lua_ls_binary == '' then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'lua' },
    once = true,
    callback = function()
      vim.notify_once(
        'lua-language-server not found in PATH. Please install:\n'
          .. '  - Nix: add pkgs.lua-language-server to home.nix\n'
          .. '  - macOS: brew install lua-language-server\n'
          .. '  - Other: https://github.com/LuaLS/lua-language-server',
        vim.log.levels.INFO
      )
    end,
  })
  return
end

local capabilities = lsp_helpers.make_capabilities()

vim.lsp.config('lua_ls', {
  cmd = { lua_ls_binary },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
  capabilities = capabilities,
  on_attach = lsp_helpers.default_on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.enable('lua_ls')
