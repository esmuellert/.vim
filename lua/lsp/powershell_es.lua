-- powershell_es: PowerShell Editor Services LSP
-- Auto-installs from GitHub releases, requires pwsh in PATH

local lsp_helpers = require('core.lsp-helpers')
local utils = require('core.utils')

local install_dir = vim.fn.stdpath('data') .. '/powershell-es'
local start_script = install_dir .. '/PowerShellEditorServices/Start-EditorServices.ps1'
local version_file = install_dir .. '/version.txt'
local cache_dir = vim.fn.stdpath('cache')

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function get_shell()
  if vim.fn.executable('pwsh') == 1 then return 'pwsh' end
  if vim.fn.executable('powershell') == 1 then return 'powershell' end
  return nil
end

local function get_installed_version()
  local f = io.open(version_file, 'r')
  if not f then return nil end
  local version = f:read('*l')
  f:close()
  return version
end

------------------------------------------------------------------------
-- Install PSES from GitHub releases (non-blocking)
------------------------------------------------------------------------
local function install_pses(on_complete)
  local shell = get_shell()
  if not shell then return end

  vim.fn.mkdir(install_dir, 'p')
  local zip_path = install_dir .. '/PowerShellEditorServices.zip'

  vim.notify('Installing PowerShell Editor Services...', vim.log.levels.INFO)

  local cmd
  if utils.is_windows() then
    cmd = {
      shell, '-NoProfile', '-Command',
      string.format(
        [[$ProgressPreference='SilentlyContinue'; ]]
          .. [[$release = Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShellEditorServices/releases/latest'; ]]
          .. [[$version = $release.tag_name -replace '^v',''; ]]
          .. [[$url = ($release.assets | Where-Object { $_.name -eq 'PowerShellEditorServices.zip' }).browser_download_url; ]]
          .. [[Invoke-WebRequest -Uri $url -OutFile '%s'; ]]
          .. [[Expand-Archive -Path '%s' -DestinationPath '%s' -Force; ]]
          .. [[Remove-Item '%s'; ]]
          .. [[if ($version) { Set-Content -Path '%s' -Value $version -NoNewline }]],
        zip_path, zip_path, install_dir, zip_path, version_file
      ),
    }
  else
    if vim.fn.executable('curl') ~= 1 or vim.fn.executable('unzip') ~= 1 then
      vim.notify('powershell_es: curl and unzip required for installation', vim.log.levels.ERROR)
      return
    end
    cmd = {
      'sh', '-c',
      string.format(
        [[VERSION=$(curl -fsSL 'https://api.github.com/repos/PowerShell/PowerShellEditorServices/releases/latest' ]]
          .. [[| grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/') && ]]
          .. [[curl -fSL "https://github.com/PowerShell/PowerShellEditorServices/releases/download/v${VERSION}/PowerShellEditorServices.zip" -o '%s' && ]]
          .. [[unzip -o -q '%s' -d '%s' && ]]
          .. [[rm -f '%s' && ]]
          .. [[printf '%%s' "$VERSION" > '%s']],
        zip_path, zip_path, install_dir, zip_path, version_file
      ),
    }
  end

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        local version = get_installed_version()
        local msg = 'PowerShell Editor Services installed!'
        if version then msg = msg .. ' (v' .. version .. ')' end
        vim.notify(msg, vim.log.levels.INFO)
        if on_complete then on_complete() end
      else
        vim.notify(
          'Failed to install PowerShell Editor Services: ' .. (result.stderr or 'unknown'),
          vim.log.levels.ERROR
        )
      end
    end)
  end)
end

------------------------------------------------------------------------
-- Configure PSES LSP
------------------------------------------------------------------------
local function setup_pses()
  local shell = get_shell()
  if not shell then return end
  if vim.fn.filereadable(start_script) == 0 then return end

  local capabilities = lsp_helpers.make_capabilities()

  local command = string.format(
    [[& '%s' -BundledModulesPath '%s' -LogPath '%s/powershell_es.log' -SessionDetailsPath '%s/powershell_es.session.json' -FeatureFlags @() -AdditionalModules @() -HostName nvim -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal]],
    start_script, install_dir, cache_dir, cache_dir
  )

  vim.lsp.config('powershell_es', {
    cmd = { shell, '-NoLogo', '-NoProfile', '-Command', command },
    filetypes = { 'ps1' },
    root_markers = { 'PSScriptAnalyzerSettings.psd1', '.git' },
    single_file_support = true,
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil
      lsp_helpers.default_on_attach(client, bufnr)
    end,
    settings = {
      powershell = {
        codeFormatting = { Preset = 'OTBS' },
      },
    },
  })

  vim.lsp.enable('powershell_es')
end

------------------------------------------------------------------------
-- Startup: setup if installed, auto-install if missing
------------------------------------------------------------------------
local shell = get_shell()
if shell then
  setup_pses()
  if vim.fn.filereadable(start_script) == 0 then
    install_pses(function() setup_pses() end)
  end
else
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'ps1' },
    once = true,
    callback = function()
      vim.notify(
        'PowerShell Editor Services requires pwsh in PATH.\n'
          .. '  Nix: add pkgs.powershell to home.nix\n'
          .. '  macOS: brew install powershell\n'
          .. '  Linux: https://aka.ms/install-powershell',
        vim.log.levels.INFO
      )
    end,
  })
end

------------------------------------------------------------------------
-- :PowershellEs command
------------------------------------------------------------------------
vim.api.nvim_create_user_command('PowershellEs', function(opts)
  local sub = opts.fargs[1]

  if sub == 'update' then
    vim.notify('Updating PowerShell Editor Services...', vim.log.levels.INFO)
    vim.fn.delete(install_dir .. '/PowerShellEditorServices', 'rf')
    vim.fn.delete(version_file)
    install_pses(function() setup_pses() end)
  elseif sub == 'status' then
    local version = get_installed_version()
    if vim.fn.filereadable(start_script) == 1 then
      local clients = vim.lsp.get_clients({ name = 'powershell_es' })
      local lsp_status = #clients > 0 and 'running' or 'not running'
      local version_str = version and ('v' .. version) or 'unknown version'
      vim.notify('powershell_es: ' .. version_str .. ', LSP ' .. lsp_status, vim.log.levels.INFO)
    else
      vim.notify('powershell_es: not installed', vim.log.levels.INFO)
    end
  elseif sub == 'reinstall' then
    vim.fn.delete(install_dir, 'rf')
    install_pses(function() setup_pses() end)
  else
    vim.notify(
      'PowershellEs: unknown subcommand. Available: update, status, reinstall',
      vim.log.levels.ERROR
    )
  end
end, {
  nargs = 1,
  complete = function() return { 'update', 'status', 'reinstall' } end,
  desc = 'Manage PowerShell Editor Services LSP',
})

-- Lowercase alias: :powershelles → :PowershellEs
vim.cmd(
  [[cnoreabbrev <expr> powershelles getcmdtype() ==# ':' && getcmdline() =~# '^powershelles' ? 'PowershellEs' : 'powershelles']]
)
