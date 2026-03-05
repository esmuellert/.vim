-- tsgo: TypeScript language server (native preview from @typescript/native-preview)
-- Auto-installs via npm, no system package needed

local lsp_helpers = require('core.lsp-helpers')
local utils = require('core.utils')

local tsgo_install_dir = vim.fn.stdpath('data') .. '/tsgo'
local tsgo_bin = tsgo_install_dir .. '/node_modules/.bin/tsgo'
if utils.is_windows() then
  tsgo_bin = tsgo_bin .. '.cmd'
end

-- Helper function to install tsgo if not present (non-blocking)
local function install_tsgo(on_complete)
  if vim.fn.executable('npm') ~= 1 then return end

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
  if vim.fn.filereadable(tsgo_bin) == 0 then
    return
  end

  local capabilities = lsp_helpers.make_capabilities()

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
      lsp_helpers.default_on_attach(client, bufnr)

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
      ['workspace/didChangeConfiguration'] = function() end,
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

  vim.lsp.enable('tsgo')
end

-- Setup tsgo immediately + install/upgrade
setup_tsgo()
install_tsgo(function()
  setup_tsgo()
end)

-- :Tsgo command
vim.api.nvim_create_user_command('Tsgo', function(opts)
  local sub = opts.fargs[1]
  if sub == 'update' then
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
    if vim.fn.filereadable(tsgo_bin) == 1 then
      local clients = vim.lsp.get_clients({ name = 'tsgo' })
      local status = #clients > 0 and 'running' or 'not running'
      vim.notify('tsgo: installed, LSP ' .. status, vim.log.levels.INFO)
    else
      vim.notify('tsgo: not installed', vim.log.levels.INFO)
    end
  elseif sub == 'reinstall' then
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
