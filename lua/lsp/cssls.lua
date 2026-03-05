-- cssls: CSS language server
-- Requires: vscode-css-language-server in PATH (from vscode-langservers-extracted)

local lsp_helpers = require('core.lsp-helpers')

local css_binary = vim.fn.exepath('vscode-css-language-server')

if css_binary == '' then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'css', 'scss', 'less' },
    once = true,
    callback = function()
      vim.notify_once(
        'vscode-css-language-server not found in PATH. Please install:\n'
          .. '  - Nix: add pkgs.vscode-langservers-extracted to home.nix\n'
          .. '  - npm: npm i -g vscode-langservers-extracted',
        vim.log.levels.INFO
      )
    end,
  })
  return
end

local capabilities = lsp_helpers.make_capabilities()

vim.lsp.config('cssls', {
  cmd = { css_binary, '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
  on_attach = lsp_helpers.default_on_attach,
})

vim.lsp.enable('cssls')
