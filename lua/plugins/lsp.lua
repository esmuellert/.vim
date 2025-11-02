-- LSP configuration

local enabled = require('config.plugins-enabled')

-- Helper function to install tsgo if not present (non-blocking)
local function install_tsgo()
  local utils = require('core.utils')
  local tsgo_install_dir = vim.fn.stdpath("data") .. "/tsgo"
  local tsgo_bin = tsgo_install_dir .. "/node_modules/.bin/tsgo"

  if utils.is_windows() then
    tsgo_bin = tsgo_bin .. ".cmd"
  end

  -- Check if already installed
  if vim.fn.filereadable(tsgo_bin) == 0 then
    vim.notify("Installing tsgo in background...", vim.log.levels.INFO)
    vim.fn.mkdir(tsgo_install_dir, "p")

    -- Install asynchronously using vim.system (native nvim async API)
    vim.system({ 'npm', 'install', '@typescript/native-preview' }, {
      text = true,
      cwd = tsgo_install_dir,
    }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify("tsgo installed successfully! Restart Neovim to activate.", vim.log.levels.INFO)
        else
          vim.notify("Failed to install tsgo. Error: " .. (result.stderr or "unknown"), vim.log.levels.ERROR)
        end
      end)
    end)
  end
end

-- Helper function to configure tsgo LSP
local function setup_tsgo()
  local utils = require('core.utils')
  local tsgo_install_dir = vim.fn.stdpath("data") .. "/tsgo"
  local tsgo_bin = tsgo_install_dir .. "/node_modules/.bin/tsgo"

  if utils.is_windows() then
    tsgo_bin = tsgo_bin .. ".cmd"
  end

  -- Only configure if tsgo is installed
  if vim.fn.filereadable(tsgo_bin) == 0 then
    return
  end

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- Configure tsgo LSP using new vim.lsp.config API (nvim 0.11+)
  vim.lsp.config('tsgo', {
    cmd = { tsgo_bin, '--lsp', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    capabilities = capabilities,
    init_options = {
      hostInfo = 'neovim',
      preferences = {
        includePackageJsonAutoImports = 'auto',
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsForImportStatements = true,
        allowIncompleteCompletions = true,
        disableSuggestions = false,
      },
      maxTsServerMemory = 8192,
    },
    on_attach = function(client, bufnr)
      -- Enable inlay hints if supported
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end

      -- Create custom command for TypeScript source-level actions
      vim.api.nvim_buf_create_user_command(bufnr, "LspTypescriptSourceAction", function()
        if client.server_capabilities.codeActionProvider then
          local source_actions = vim.tbl_filter(function(action)
            return vim.startswith(action, "source.")
          end, client.server_capabilities.codeActionProvider.codeActionKinds or {})

          vim.lsp.buf.code_action({ context = { only = source_actions } })
        end
      end, { desc = "TypeScript source actions" })
    end,
    handlers = {
      -- Handle rename requests for code actions like extract function/type
      ["_typescript.rename"] = function(_, result, ctx)
        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        vim.lsp.util.show_document({
          uri = result.textDocument.uri,
          range = { start = result.position, ["end"] = result.position },
        }, client.offset_encoding)
        vim.lsp.buf.rename()
        return vim.NIL
      end,
    },
    commands = {
      -- Handle show references command - displays in quickfix list
      ["editor.action.showReferences"] = function(command, ctx)
        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        local file_uri, position, references = unpack(command.arguments)

        local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
        vim.fn.setqflist({}, " ", {
          title = command.title,
          items = quickfix_items,
          context = { command = command, bufnr = ctx.bufnr },
        })

        vim.lsp.util.show_document({
          uri = file_uri,
          range = { start = position, ["end"] = position },
        }, client.offset_encoding)

        vim.cmd("botright copen")
      end,
    },
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
        },
        implicitProjectConfig = { allowJs = true },
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
        },
        implicitProjectConfig = { checkJs = true },
      },
    },
  })

  -- Enable tsgo LSP server
  vim.lsp.enable('tsgo')
end

return {
  ------------------------------------------------------------------------
  -- 🛠️ mason.nvim: Tool to manage LSPs, DAPs, linters, and formatters
  ------------------------------------------------------------------------
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = enabled.lsp and enabled.mason,
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

      -- Setup mason first with custom registry for roslyn
      require('mason').setup({
        registries = {
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',
        },
      })

      -- Install and configure tsgo on first VimEnter
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          install_tsgo()
          setup_tsgo()
        end,
      })

      -- Determine which servers to install based on architecture
      local utils = require('core.utils')
      local ensure_installed = { 'html', 'cssls', 'lua_ls', 'powershell_es' }

      if not utils.is_arm64() then
        table.insert(ensure_installed, 'clangd')
        table.insert(ensure_installed, 'lemminx')
      end

      return {
        ensure_installed = ensure_installed,
        handlers = {
          function(server)
            lspconfig[server].setup({
              capabilities = capabilities,
              on_attach = default_on_attach,
            })
          end,
          ['clangd'] = function(server)
            -- Disable clangd on Windows and ARM64
            local utils = require('core.utils')
            if utils.is_windows() or utils.is_arm64() then
              return
            end

            -- Check clangd version to determine if it's clangd-21+
            local handle = io.popen('clangd --version 2>&1')
            local version_output = handle and handle:read('*a') or ''
            if handle then handle:close() end

            local is_clangd_21_plus = version_output:match('clangd version (%d+)') and
                                       tonumber(version_output:match('clangd version (%d+)')) >= 21

            -- Enhanced capabilities for clangd
            local clangd_capabilities = vim.deepcopy(capabilities)
            clangd_capabilities.offsetEncoding = { 'utf-16' }
            clangd_capabilities.textDocument = clangd_capabilities.textDocument or {}
            clangd_capabilities.textDocument.completion = clangd_capabilities.textDocument.completion or {}
            clangd_capabilities.textDocument.completion.editsNearCursor = true

            local clangd_cmd = {
              'clangd',
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
            }

            -- Add clangd-21+ specific features
            if is_clangd_21_plus then
              table.insert(clangd_cmd, '--header-insertion-decorators')
              table.insert(clangd_cmd, '--ranking-model=decision_forest')
              table.insert(clangd_cmd, '--limit-results=0')
            end

            local clangd_on_attach = function(client, bufnr)
              default_on_attach(client, bufnr)

              -- Switch between source/header files (clangd extension)
              vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<CR>',
                { buffer = bufnr, desc = 'Switch Source/Header' })

              -- Symbol info under cursor
              vim.keymap.set('n', '<leader>ci', '<cmd>ClangdSymbolInfo<CR>',
                { buffer = bufnr, desc = 'Symbol Info' })

              -- Type hierarchy
              vim.keymap.set('n', '<leader>ct', '<cmd>ClangdTypeHierarchy<CR>',
                { buffer = bufnr, desc = 'Type Hierarchy' })
            end

            lspconfig[server].setup({
              on_attach = clangd_on_attach,
              capabilities = clangd_capabilities,
              cmd = clangd_cmd,
              init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
                compilationDatabasePath = '',
                fallbackFlags = {},
              },
              settings = {
                clangd = {
                  InlayHints = {
                    Enabled = true,
                    ParameterNames = true,
                    DeducedTypes = true,
                  },
                },
              },
              handlers = {
                -- Custom handler for clangd's file status updates
                ['textDocument/clangd.fileStatus'] = function(_, result, ctx)
                  -- Optionally handle file status notifications
                  return vim.NIL
                end,
              },
            })
          end,
          ['lua_ls'] = function(server)
            lspconfig[server].setup({
              on_attach = default_on_attach,
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = {
                    version = 'LuaJIT',
                  },
                  diagnostics = {
                    globals = { 'vim' },
                  },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file('', true),
                    checkThirdParty = false,
                  },
                  telemetry = {
                    enable = false,
                  },
                },
              },
            })
          end,
        },
      }
    end,
    config = function(_, opts)
      -- Setup Mason LSP servers via handlers
      require('mason-lspconfig').setup(opts)

      -- Configure SourceKit directly (builtin, not installed by Mason)
      -- Using new vim.lsp.config API for Neovim 0.11+
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

      -- Use new vim.lsp.config API for Neovim 0.11+
      if vim.lsp.config then
        vim.lsp.config.sourcekit = {
          cmd = { resolved },
          filetypes = { 'swift' },
          root_dir = vim.fs.root,
          capabilities = capabilities,
        }

        -- Register the on_attach handler
        vim.api.nvim_create_autocmd('LspAttach', {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == 'sourcekit' then
              on_attach(client, args.buf)
              if client.server_capabilities then
                client.offset_encoding = 'utf-8'
              end
            end
          end,
        })
      else
        -- Fallback to old API for older Neovim versions
        local lspconfig = require('lspconfig')
        lspconfig.sourcekit.setup({
          cmd = { resolved },
          filetypes = { 'swift' },
          capabilities = capabilities,
          on_attach = on_attach,
          on_init = function(client)
            client.offset_encoding = 'utf-8'
          end,
        })
      end
    end,
  },

  ------------------------------------------------------------------------
  --- 🛞 fidget.nvim: Standalone UI for LSP progress notifications
  ------------------------------------------------------------------------
  {
    'j-hui/fidget.nvim',
    enabled = enabled.fidget,
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
    enabled = enabled.lspsaga,
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
