-- gopls: Go language server
-- Requires: gopls in PATH

local lsp_helpers = require('core.lsp-helpers')

local gopls_binary = vim.fn.exepath('gopls')

if gopls_binary == '' then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'go', 'gomod', 'gowork', 'gotmpl' },
    once = true,
    callback = function()
      vim.notify_once(
        'gopls not found in PATH. Please install gopls:\n'
          .. '  - Nix: add pkgs.gopls to home.nix\n'
          .. '  - Go: go install golang.org/x/tools/gopls@latest\n'
          .. '  - macOS: brew install gopls',
        vim.log.levels.INFO
      )
    end,
  })
  return
end

local capabilities = lsp_helpers.make_capabilities()

vim.lsp.config('gopls', {
  cmd = { gopls_binary },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  capabilities = capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      staticcheck = true,
      gofumpt = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      codelenses = {
        gc_details = true,
        generate = true,
        test = true,
        tidy = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      directoryFilters = { '-.git', '-node_modules' },
      semanticTokens = true,
    },
  },
})

vim.lsp.enable('gopls')

-- gopls-specific keymaps on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('GoplsLspAttach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= 'gopls' then
      return
    end

    lsp_helpers.default_on_attach(client, args.buf)
  end,
})
