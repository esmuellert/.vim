-- lemminx: XML language server
-- Requires: lemminx in PATH

local lsp_helpers = require('core.lsp-helpers')
local utils = require('core.utils')

-- lemminx is not available on ARM64
if utils.is_arm64() then
  return
end

local lemminx_binary = vim.fn.exepath('lemminx')

if lemminx_binary == '' then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
    once = true,
    callback = function()
      vim.notify_once(
        'lemminx not found in PATH. Please install:\n'
          .. '  - Nix: add pkgs.lemminx to home.nix\n'
          .. '  - Other: https://github.com/eclipse/lemminx',
        vim.log.levels.INFO
      )
    end,
  })
  return
end

local capabilities = lsp_helpers.make_capabilities()

vim.lsp.config('lemminx', {
  cmd = { lemminx_binary },
  filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
  root_markers = { '.git' },
  capabilities = capabilities,
  on_attach = lsp_helpers.default_on_attach,
})

vim.lsp.enable('lemminx')
