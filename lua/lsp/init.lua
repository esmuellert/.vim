-- LSP configuration loader
-- Each server is configured in its own file under lua/lsp/
-- Shared keymaps are set up here via LspAttach autocmd

local lsp_helpers = require('core.lsp-helpers')

------------------------------------------------------------------------
-- Shared LSP keymaps (applied to all LSP servers)
------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('NativeLspKeymaps', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local opts = function(desc)
      return { buffer = bufnr, desc = desc }
    end
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts('Goto Definition'))
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts('References'))
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts('Goto Implementation'))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts('Hover Documentation'))
    vim.keymap.set('n', '<leader>rn', function()
      return ':IncRename ' .. vim.fn.expand('<cword>')
    end, { buffer = bufnr, desc = 'Rename Symbol', expr = true })
    vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action, opts('Code Action'))
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts('Type Definition'))
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts('Goto Declaration'))
    vim.keymap.set('n', '<leader>sh', vim.lsp.buf.signature_help, opts('Signature Help'))
  end,
})

------------------------------------------------------------------------
-- Load individual LSP server configs
------------------------------------------------------------------------
require('lsp.clangd')
require('lsp.tsgo')
require('lsp.gopls')
require('lsp.lua_ls')
require('lsp.html')
require('lsp.cssls')
require('lsp.lemminx')
require('lsp.roslyn')
require('lsp.powershell_es')
