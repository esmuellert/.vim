-- clangd: C/C++ language server
-- Requires: clangd in PATH (install via system package manager)

local lsp_helpers = require('core.lsp-helpers')
local utils = require('core.utils')

-- Skip on Windows
if utils.is_windows() then
  return
end

-- Find clangd binary
local clangd_binary = vim.fn.exepath('clangd')
if clangd_binary == '' then
  clangd_binary = vim.fn.exepath('clangd-21')
end

if clangd_binary == '' then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    once = true,
    callback = function()
      vim.notify_once(
        'clangd not found in PATH. Please install clangd:\n'
          .. '  - Ubuntu/Debian: sudo apt install clangd-21\n'
          .. '  - macOS: brew install llvm\n'
          .. '  - Nix: add pkgs.clang-tools to home.nix\n'
          .. '  - Other: https://clangd.llvm.org/installation',
        vim.log.levels.INFO
      )
    end,
  })
  return
end

-- Get clangd version
local result = vim.system({ clangd_binary, '--version' }, { text = true }):wait()
local version_output = result.stdout or ''
local version_major = tonumber(version_output:match('clangd version (%d+)'))
local is_clangd_21_plus = version_major and version_major >= 21

-- Build command line arguments
local clangd_cmd = {
  clangd_binary,
  '--background-index',
  '--clang-tidy',
  '--header-insertion=iwyu',
  '--completion-style=detailed',
  '--function-arg-placeholders',
  '--fallback-style=llvm',
  '--pch-storage=memory',
  '--all-scopes-completion',
  '--completion-parse=auto',
  '--enable-config',
  '--offset-encoding=utf-16',
  '--inlay-hints',
}

if is_clangd_21_plus then
  table.insert(clangd_cmd, '--header-insertion-decorators')
  table.insert(clangd_cmd, '--ranking-model=decision_forest')
  table.insert(clangd_cmd, '--limit-results=0')
end

-- Get capabilities
local capabilities = lsp_helpers.make_capabilities()
capabilities.offsetEncoding = { 'utf-16' }
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.completion = capabilities.textDocument.completion or {}
capabilities.textDocument.completion.editsNearCursor = true

-- Configure clangd
vim.lsp.config('clangd', {
  cmd = clangd_cmd,
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
  capabilities = capabilities,
  settings = {
    clangd = {
      InlayHints = {
        Enabled = true,
        ParameterNames = true,
        DeducedTypes = true,
      },
    },
  },
})

vim.lsp.enable('clangd')

-- Clangd-specific keymaps on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('ClangdLspAttach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= 'clangd' then
      return
    end

    local bufnr = args.buf
    lsp_helpers.default_on_attach(client, bufnr)

    vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<CR>', { buffer = bufnr, desc = 'Switch Source/Header' })
    vim.keymap.set('n', '<leader>ci', '<cmd>ClangdSymbolInfo<CR>', { buffer = bufnr, desc = 'Symbol Info' })
    vim.keymap.set('n', '<leader>ct', '<cmd>ClangdTypeHierarchy<CR>', { buffer = bufnr, desc = 'Type Hierarchy' })
  end,
})
