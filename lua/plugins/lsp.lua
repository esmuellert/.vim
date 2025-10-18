-- LSP configuration

return {
  ------------------------------------------------------------------------
  -- 🛠️ mason.nvim: Tool to manage LSPs, DAPs, linters, and formatters
  ------------------------------------------------------------------------
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
    },
    event = "BufEnter",
    opts = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')
      local default_on_attach = function(client, bufnr)
        if client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end
      
      -- Setup mason first
      require('mason').setup({})
      
      return {
        ensure_installed = { 'ts_ls', 'html', 'cssls', 'lua_ls', 'lemminx', 'powershell_es' },
        handlers = {
          function(server)
            lspconfig[server].setup({
              capabilities = capabilities,
              on_attach = default_on_attach,
            })
          end,
          ['lua_ls'] = function(server)
            lspconfig[server].setup({
              on_attach = default_on_attach,
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { 'vim' },
                  },
                },
              },
            })
          end,
          ['ts_ls'] = function(server)
            lspconfig[server].setup({
              on_attach = default_on_attach,
              root_dir = function(_, bufnr)
                return vim.fs.root(bufnr, { '.git' })
              end,
              capabilities = capabilities,
              settings = {
                typescript = {
                  inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  }
                },
                javascript = {
                  inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  }
                }
              }
            })
          end,
        },
      }
    end,
    config = function(_, opts)
      -- Setup Mason LSP servers via handlers
      require('mason-lspconfig').setup(opts)

      -- Configure SourceKit directly (builtin, not installed by Mason)
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local on_attach = function(client, bufnr)
        if client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end
      local resolved = vim.trim(vim.fn.system('xcrun -f sourcekit-lsp'))
      if resolved == '' or vim.v.shell_error ~= 0 then
        resolved = 'sourcekit-lsp'
      end
      lspconfig.sourcekit.setup({
        cmd = { resolved },
        filetypes = { 'swift' },
        capabilities = capabilities,
        on_attach = on_attach,
        on_init = function(client)
          client.offset_encoding = 'utf-8'
        end,
      })
    end,
  },

  ------------------------------------------------------------------------
  --- 🛞 fidget.nvim: Standalone UI for LSP progress notifications
  ------------------------------------------------------------------------
  {
    'j-hui/fidget.nvim',
    event = 'BufEnter',
    config = function()
      require("fidget").setup({})
    end,
  },

  ------------------------------------------------------------------------
  --- 🌀 lspsaga.nvim: Light-weight LSP UI
  ------------------------------------------------------------------------
  {
    'nvimdev/lspsaga.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    opts = function()
      return {
        ui = {
          code_action = '',
        },
      }
    end,
    keys = {
      {
        'gd',
        '<cmd>Lspsaga goto_definition<CR>',
        desc = 'Goto Definition',
        mode = 'n',
        noremap = true,
        silent = true
      },
      { 'gr',         '<cmd>Lspsaga finder<CR>',      desc = 'Lspsaga Finder',                 mode = 'n', noremap = true, silent = true },
      { 'gi',         '<cmd>Lspsaga finder imp<CR>',  desc = 'Lspsaga Finder Implementations', mode = 'n', noremap = true, silent = true },
      { 'K',          '<cmd>Lspsaga hover_doc<CR>',   desc = 'Hover Documentation',            mode = 'n', noremap = true, silent = true },
      { 'rn',         '<cmd>Lspsaga rename<CR>',      desc = 'Rename Symbol',                  mode = 'n', noremap = true, silent = true },
      { '<leader>ac', '<cmd>Lspsaga code_action<CR>', desc = 'Code Action',                    mode = 'n', noremap = true, silent = true },
      { '<leader>fm', vim.lsp.buf.format,             desc = 'Format Buffer',                  mode = 'n', noremap = true, silent = true },
    },
  },
}
