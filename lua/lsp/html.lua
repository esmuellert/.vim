-- html: HTML language server
-- Requires: vscode-html-language-server in PATH (from vscode-langservers-extracted)

local lsp_helpers = require('core.lsp-helpers')

local html_binary = vim.fn.exepath('vscode-html-language-server')

if html_binary == '' then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'html' },
    once = true,
    callback = function()
      vim.notify_once(
        'vscode-html-language-server not found in PATH. Please install:\n'
          .. '  - Nix: add pkgs.vscode-langservers-extracted to home.nix\n'
          .. '  - npm: npm i -g vscode-langservers-extracted',
        vim.log.levels.INFO
      )
    end,
  })
  return
end

local capabilities = lsp_helpers.make_capabilities()

vim.lsp.config('html', {
  cmd = { html_binary, '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
  on_attach = lsp_helpers.default_on_attach,
})

vim.lsp.enable('html')
