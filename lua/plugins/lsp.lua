-- LSP configuration

local enabled = require('config.plugins-enabled')
local lsp_helpers = require('core.lsp-helpers')

------------------------------------------------------------------------
-- clangd: C/C++ language server using vim.lsp.config (Neovim 0.11+)
------------------------------------------------------------------------
-- Helper function to configure clangd using vim.lsp.config
local function setup_clangd()
  local utils = require('core.utils')

  -- Skip on Windows
  if utils.is_windows() then
    return
  end

  -- Check Neovim version
  local nvim_version = vim.version()
  if nvim_version.major == 0 and nvim_version.minor < 11 then
    vim.notify('Neovim 0.11+ required for native clangd support. Please upgrade Neovim.', vim.log.levels.WARN)
    return
  end

  -- Find clangd binary using vim.fn.exepath (searches $PATH)
  local clangd_binary = vim.fn.exepath('clangd')
  if clangd_binary == '' then
    clangd_binary = vim.fn.exepath('clangd-21')
  end

  if clangd_binary == '' then
    -- Defer warning until a C/C++ file is actually opened
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
      once = true,
      callback = function()
        vim.notify_once(
          'clangd not found in PATH. Please install clangd:\n'
            .. '  - Ubuntu/Debian: sudo apt install clangd-21\n'
            .. '  - macOS: brew install llvm\n'
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

  -- Parse version
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

  -- Add clangd-21+ specific features
  if is_clangd_21_plus then
    table.insert(clangd_cmd, '--header-insertion-decorators')
    table.insert(clangd_cmd, '--ranking-model=decision_forest')
    table.insert(clangd_cmd, '--limit-results=0')
  end

  -- Get capabilities from blink.cmp (or fallback to native)
  local capabilities = lsp_helpers.make_capabilities()
  capabilities.offsetEncoding = { 'utf-16' }
  capabilities.textDocument = capabilities.textDocument or {}
  capabilities.textDocument.completion = capabilities.textDocument.completion or {}
  capabilities.textDocument.completion.editsNearCursor = true

  -- Configure clangd using vim.lsp.config
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

  -- Enable clangd
  vim.lsp.enable('clangd')

  -- Setup clangd-specific keymaps and commands on attach
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('ClangdLspAttach', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name ~= 'clangd' then
        return
      end

      local bufnr = args.buf

      -- Enable inlay hints if supported
      lsp_helpers.default_on_attach(client, bufnr)

      -- Clangd-specific keymaps
      vim.keymap.set(
        'n',
        '<leader>ch',
        '<cmd>ClangdSwitchSourceHeader<CR>',
        { buffer = bufnr, desc = 'Switch Source/Header' }
      )
      vim.keymap.set('n', '<leader>ci', '<cmd>ClangdSymbolInfo<CR>', { buffer = bufnr, desc = 'Symbol Info' })
      vim.keymap.set('n', '<leader>ct', '<cmd>ClangdTypeHierarchy<CR>', { buffer = bufnr, desc = 'Type Hierarchy' })
    end,
  })

end

------------------------------------------------------------------------
-- tsgo: TypeScript language server (native preview from @typescript/native-preview)
------------------------------------------------------------------------
-- Helper function to install tsgo if not present (non-blocking)
local function install_tsgo(on_complete)
  if vim.fn.executable('npm') ~= 1 then return end
  local utils = require('core.utils')
  local tsgo_install_dir = vim.fn.stdpath('data') .. '/tsgo'
  local tsgo_bin = tsgo_install_dir .. '/node_modules/.bin/tsgo'

  if utils.is_windows() then
    tsgo_bin = tsgo_bin .. '.cmd'
  end

  vim.fn.mkdir(tsgo_install_dir, 'p')

  -- Always run npm install @latest to auto-upgrade on startup
  vim.system({ 'npm', 'install', '@typescript/native-preview@latest' }, {
    text = true,
    cwd = tsgo_install_dir,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        if on_complete then on_complete() end
      else
        vim.notify('Failed to install/update tsgo: ' .. (result.stderr or 'unknown'), vim.log.levels.ERROR)
      end
    end)
  end)
end

-- Helper function to configure tsgo LSP
local function setup_tsgo()
  local utils = require('core.utils')
  local tsgo_install_dir = vim.fn.stdpath('data') .. '/tsgo'
  
  -- Use the npm bin shim which automatically selects the correct platform-specific exe
  local tsgo_bin = tsgo_install_dir .. '/node_modules/.bin/tsgo'
  if utils.is_windows() then
    tsgo_bin = tsgo_bin .. '.cmd'
  end

  -- Only configure if tsgo is installed
  if vim.fn.filereadable(tsgo_bin) == 0 then
    return
  end

  local capabilities = lsp_helpers.make_capabilities()

  -- IMPORTANT: Must modify vim.lsp.config.tsgo.cmd BEFORE calling vim.lsp.enable()
  -- because vim.lsp.enable() reads the config at enable-time
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
      -- Enable inlay hints if supported (tsgo doesn't support yet as of 2025-11-05)
      lsp_helpers.default_on_attach(client, bufnr)

      -- Create custom command for TypeScript source-level actions
      vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptSourceAction', function()
        if client.server_capabilities.codeActionProvider then
          local source_actions = vim.tbl_filter(function(action)
            return vim.startswith(action, 'source.')
          end, client.server_capabilities.codeActionProvider.codeActionKinds or {})

          vim.lsp.buf.code_action({ context = { only = source_actions, diagnostics = {} } })
        end
      end, { desc = 'TypeScript source actions' })
    end,
    handlers = {
      -- Intercept workspace/didChangeConfiguration to prevent tsgo from logging error
      -- tsgo's handler requires session to be initialized first
      ['workspace/didChangeConfiguration'] = function() end,
      -- Handle rename requests for code actions like extract function/type
      ['_typescript.rename'] = function(_, result, ctx)
        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        vim.lsp.util.show_document({
          uri = result.textDocument.uri,
          range = { start = result.position, ['end'] = result.position },
        }, client.offset_encoding)
        vim.lsp.buf.rename()
        return vim.NIL
      end,
    },
    commands = {
      -- Handle show references command - displays in quickfix list
      ['editor.action.showReferences'] = function(command, ctx)
        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        local file_uri, position, references = unpack(command.arguments)

        local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
        vim.fn.setqflist({}, ' ', {
          title = command.title,
          items = quickfix_items,
          context = { command = command, bufnr = ctx.bufnr },
        })

        vim.lsp.util.show_document({
          uri = file_uri,
          range = { start = position, ['end'] = position },
        }, client.offset_encoding)

        vim.cmd('botright copen')
      end,
    },
  })

  -- Enable tsgo LSP server
  vim.lsp.enable('tsgo')
end

vim.api.nvim_create_user_command('Tsgo', function(opts)
  local sub = opts.fargs[1]
  if sub == 'update' then
    local tsgo_install_dir = vim.fn.stdpath('data') .. '/tsgo'
    vim.notify('Updating tsgo...', vim.log.levels.INFO)
    vim.system({ 'npm', 'install', '@typescript/native-preview@latest' }, {
      text = true,
      cwd = tsgo_install_dir,
    }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify('tsgo updated! Restart Neovim to activate.', vim.log.levels.INFO)
        else
          vim.notify('tsgo update failed: ' .. (result.stderr or 'unknown'), vim.log.levels.ERROR)
        end
      end)
    end)
  elseif sub == 'status' then
    local tsgo_install_dir = vim.fn.stdpath('data') .. '/tsgo'
    local tsgo_bin = tsgo_install_dir .. '/node_modules/.bin/tsgo'
    if vim.fn.filereadable(tsgo_bin) == 1 then
      local clients = vim.lsp.get_clients({ name = 'tsgo' })
      local status = #clients > 0 and 'running' or 'not running'
      vim.notify('tsgo: installed, LSP ' .. status, vim.log.levels.INFO)
    else
      vim.notify('tsgo: not installed', vim.log.levels.INFO)
    end
  elseif sub == 'reinstall' then
    local tsgo_install_dir = vim.fn.stdpath('data') .. '/tsgo'
    vim.fn.delete(tsgo_install_dir, 'rf')
    install_tsgo(function() setup_tsgo() end)
  else
    vim.notify('Tsgo: unknown subcommand. Available: update, status, reinstall', vim.log.levels.ERROR)
  end
end, {
  nargs = 1,
  complete = function() return { 'update', 'status', 'reinstall' } end,
  desc = 'Manage tsgo TypeScript LSP',
})

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
    },
    event = { 'BufReadPost', 'BufNewFile' },
    opts = function()
      local capabilities = lsp_helpers.make_capabilities()
      local lspconfig = require('lspconfig')

      -- Setup mason first with custom registry for roslyn
      require('mason').setup({
        registries = {
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',
        },
      })

      -- Setup clangd immediately (not deferred)
      if enabled.clangd ~= false then
        setup_clangd()
      end

      -- Setup tsgo immediately (VimEnter already fired by the time this plugin loads)
      if enabled.tsgo ~= false then
        setup_tsgo() -- Try immediately (works if already installed)
        install_tsgo(function()
          setup_tsgo() -- Re-run after install/upgrade completes
        end)
      end

      -- Determine which servers to install based on architecture
      local utils = require('core.utils')
      -- Exclude clangd from Mason - it's configured separately via vim.lsp.config
      local ensure_installed = { 'html', 'cssls', 'lua_ls' }

      if not utils.is_arm64() then
        table.insert(ensure_installed, 'lemminx')
      end

      return {
        ensure_installed = ensure_installed,
        handlers = {
          function(server)
            lspconfig[server].setup({
              capabilities = capabilities,
              on_attach = lsp_helpers.default_on_attach,
            })
          end,
          ['lua_ls'] = function(server)
            lspconfig[server].setup({
              on_attach = lsp_helpers.default_on_attach,
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
                    library = { vim.env.VIMRUNTIME },
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
    end,
  },

  ------------------------------------------------------------------------
  --- 🔑 Native LSP keymaps (replaces lspsaga)
  ------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
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
    end,
  },
}
