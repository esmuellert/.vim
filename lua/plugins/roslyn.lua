-- Native Roslyn LSP configuration for C# development
-- Per-project loading for optimal performance in large solutions

local enabled = require('config.plugins-enabled')

------------------------------------------------------------------------
-- Helper: Install Roslyn LSP if not present (non-blocking)
------------------------------------------------------------------------
local function install_roslyn()
  local utils = require('core.utils')
  
  -- Only on Windows
  if not utils.is_windows() then
    return
  end
  
  local roslyn_dir = vim.fn.stdpath("data") .. "/roslyn-lsp"
  local roslyn_bin = roslyn_dir .. "/packages/Microsoft.CodeAnalysis.LanguageServer.win-x64/content/LanguageServer/win-x64/Microsoft.CodeAnalysis.LanguageServer.exe"
  
  -- Check if already installed
  if vim.fn.filereadable(roslyn_bin) == 0 then
    -- Use fidget for non-blocking notification
    local ok, fidget = pcall(require, 'fidget')
    if ok then
      fidget.notify("Installing Microsoft Roslyn Language Service...", vim.log.levels.INFO, { key = "roslyn_install" })
    else
      vim.notify("Installing Microsoft Roslyn Language Service in background...", vim.log.levels.INFO)
    end
    vim.fn.mkdir(roslyn_dir, "p")
    
    -- Create a dummy project file for NuGet restore
    local project_content = [[<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net9.0</TargetFramework>
  </PropertyGroup>
</Project>]]
    
    local project_file = roslyn_dir .. "/roslyn-lsp.csproj"
    local file = io.open(project_file, "w")
    if file then
      file:write(project_content)
      file:close()
    end
    
    -- Install using NuGet (ignoring dependencies since it's self-contained)
    vim.system({
      'nuget', 'install', 'Microsoft.CodeAnalysis.LanguageServer.win-x64',
      '-Version', '5.0.0-1.25277.114',
      '-OutputDirectory', roslyn_dir .. '/packages',
      '-ExcludeVersion',
      '-DependencyVersion', 'Ignore'
    }, {
      text = true,
      cwd = roslyn_dir,
    }, function(result)
      vim.schedule(function()
        local ok, fidget = pcall(require, 'fidget')
        if result.code == 0 then
          if ok then
            fidget.notify("Roslyn Language Service installed! Restart Neovim to activate.", vim.log.levels.INFO, { key = "roslyn_install" })
          else
            vim.notify("Roslyn Language Service installed successfully! Restart Neovim to activate.", vim.log.levels.INFO)
          end
        else
          if ok then
            fidget.notify("Failed to install Roslyn Language Service", vim.log.levels.ERROR, { key = "roslyn_install", annote = result.stderr or "unknown" })
          else
            vim.notify("Failed to install Roslyn Language Service. Error: " .. (result.stderr or "unknown"), vim.log.levels.ERROR)
          end
        end
      end)
    end)
  end
end

------------------------------------------------------------------------
-- Helper: Find nearest .csproj or .sln file for workspace root
------------------------------------------------------------------------
local function find_workspace_root(filepath)
  local path = filepath
  
  -- First try to find .sln (solution root)
  while path and path ~= "/" and path ~= "C:\\" do
    path = vim.fn.fnamemodify(path, ":h")
    
    local handle = vim.loop.fs_scandir(path)
    if handle then
      while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        
        if type == "file" and name:match("%.sln$") then
          return path  -- Return solution root
        end
      end
    end
  end
  
  -- Fallback: find nearest .csproj
  path = filepath
  while path and path ~= "/" and path ~= "C:\\" do
    path = vim.fn.fnamemodify(path, ":h")
    
    local handle = vim.loop.fs_scandir(path)
    if handle then
      while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        
        if type == "file" and name:match("%.csproj$") then
          return vim.fn.fnamemodify(path, ":h")  -- Return parent of project
        end
      end
    end
  end
  
  return nil
end

------------------------------------------------------------------------
-- Global LSP instance tracking
------------------------------------------------------------------------
local roslyn_client_id = nil  -- Single global instance

------------------------------------------------------------------------
-- Helper: Setup single global Roslyn LSP instance
------------------------------------------------------------------------
local function setup_roslyn_lsp(workspace_root)
  local utils = require('core.utils')
  
  if not utils.is_windows() then
    vim.notify("Roslyn Language Service only supported on Windows", vim.log.levels.WARN)
    return
  end
  
  -- Check if dotnet is available
  if vim.fn.executable('dotnet') == 0 then
    vim.notify("dotnet not found. Roslyn Language Service requires .NET SDK.", vim.log.levels.ERROR)
    return
  end
  
  local roslyn_bin = vim.fn.stdpath("data") .. "/roslyn-lsp/packages/Microsoft.CodeAnalysis.LanguageServer.win-x64/content/LanguageServer/win-x64/Microsoft.CodeAnalysis.LanguageServer.exe"
  
  if vim.fn.filereadable(roslyn_bin) == 0 then
    vim.notify("Roslyn Language Service not installed. Installing...", vim.log.levels.INFO)
    install_roslyn()
    return
  end
  
  -- Check if already running
  if roslyn_client_id then
    local client = vim.lsp.get_client_by_id(roslyn_client_id)
    if client then
      vim.notify("Roslyn Language Service already running", vim.log.levels.INFO)
      return roslyn_client_id
    end
  end
  
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  
  -- Roslyn LSP requires specific command line args
  local log_dir = vim.fn.stdpath("data") .. "/roslyn-lsp/logs"
  vim.fn.mkdir(log_dir, "p")
  
  vim.lsp.config('roslyn', {
    cmd = { 
      roslyn_bin,
      '--logLevel', 'Information',
      '--extensionLogDirectory', log_dir,
      '--stdio'
    },
    filetypes = { 'cs' },
    root_dir = workspace_root,  -- Use solution root for workspace
    single_file_support = false,
    capabilities = capabilities,
    -- Add Roslyn-specific handlers
    handlers = {
      -- Roslyn project restore notification (can be ignored or handled)
      ['workspace/_roslyn_projectNeedsRestore'] = function()
        return vim.NIL
      end,
    },
    on_init = function(client, initialize_result)
      -- Get version from initialize result
      local ok, fidget = pcall(require, 'fidget')
      if initialize_result and initialize_result.serverInfo then
        local version = initialize_result.serverInfo.version or "5.0.0-1.25277.114"
        if ok then
          fidget.notify("Roslyn Language Service v" .. version .. " initialized", vim.log.levels.INFO, { key = "roslyn_init" })
        else
          vim.notify(string.format("Roslyn Language Service v%s initialized", version), vim.log.levels.INFO)
        end
      else
        if ok then
          fidget.notify("Roslyn Language Service v5.0.0-1.25277.114 initialized", vim.log.levels.INFO, { key = "roslyn_init" })
        else
          vim.notify("Roslyn Language Service v5.0.0-1.25277.114 initialized", vim.log.levels.INFO)
        end
      end
    end,
    on_attach = function(client, bufnr)
      roslyn_client_id = client.id
      
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
      
      -- Use fidget for non-blocking notification
      local ok, fidget = pcall(require, 'fidget')
      if ok then
        local buf_count = #vim.lsp.get_buffers_by_client_id(client.id)
        fidget.notify("Attached to " .. buf_count .. " buffer" .. (buf_count > 1 and "s" or ""), vim.log.levels.INFO, { 
          key = "roslyn_attach",
          annote = "Roslyn"
        })
      else
        vim.notify("Roslyn Language Service attached", vim.log.levels.INFO)
      end
    end,
    on_exit = function()
      roslyn_client_id = nil
    end,
    settings = {
      -- CRITICAL: Limit analysis to open files only
      ['csharp|background_analysis'] = {
        dotnet_analyzer_diagnostics_scope = 'openFiles',
        dotnet_compiler_diagnostics_scope = 'openFiles',
      },
      ['csharp|inlay_hints'] = {
        csharp_enable_inlay_hints_for_implicit_object_creation = true,
        csharp_enable_inlay_hints_for_implicit_variable_types = true,
        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
        csharp_enable_inlay_hints_for_types = true,
        dotnet_enable_inlay_hints_for_indexer_parameters = true,
        dotnet_enable_inlay_hints_for_literal_parameters = true,
        dotnet_enable_inlay_hints_for_object_creation_parameters = true,
        dotnet_enable_inlay_hints_for_other_parameters = true,
        dotnet_enable_inlay_hints_for_parameters = true,
        dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
      },
      ['csharp|code_lens'] = {
        dotnet_enable_references_code_lens = true,
        dotnet_enable_tests_code_lens = true,
      },
      ['csharp|completion'] = {
        dotnet_provide_regex_completions = true,
        dotnet_show_completion_items_from_unimported_namespaces = true,
        dotnet_show_name_completion_suggestions = true,
      },
      ['csharp|symbol_search'] = {
        dotnet_search_reference_assemblies = true,
      },
      ['csharp|formatting'] = {
        dotnet_organize_imports_on_format = true,
      },
    },
  })
  
  -- Enable the LSP
  vim.lsp.enable('roslyn')
  
  return roslyn_client_id
end

------------------------------------------------------------------------
-- Main setup
------------------------------------------------------------------------
if enabled.lsp and enabled.roslyn then
  -- Install Roslyn LSP on startup
  vim.schedule(function()
    install_roslyn()
  end)
  
  -- Auto-attach to C# files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "cs",
    callback = function(args)
      local filepath = vim.api.nvim_buf_get_name(args.buf)
      
      if filepath == "" then
        return
      end
      
      -- Find workspace root (solution or project parent)
      local workspace_root = find_workspace_root(filepath)
      
      if workspace_root then
        -- Setup single global LSP instance if not already running
        setup_roslyn_lsp(workspace_root)
      else
        vim.notify("No .sln or .csproj found for: " .. filepath, vim.log.levels.WARN)
      end
    end,
  })
  
  -- Custom commands
  vim.api.nvim_create_user_command('Roslyn', function(opts)
    local subcommand = opts.fargs[1]
    
    if subcommand == 'restart' then
      -- Use native LSP API to find roslyn client
      local clients = vim.lsp.get_clients({ name = 'roslyn' })
      
      if #clients > 0 then
        local client = clients[1]
        vim.lsp.stop_client(client.id, true)
        vim.notify("Restarting Roslyn Language Service...", vim.log.levels.INFO)
        vim.defer_fn(function()
          local filepath = vim.api.nvim_buf_get_name(0)
          local workspace_root = find_workspace_root(filepath)
          if workspace_root then
            setup_roslyn_lsp(workspace_root)
          end
        end, 1000)
      else
        vim.notify("No Roslyn Language Service instance running", vim.log.levels.WARN)
      end
      
    elseif subcommand == 'start' then
      local filepath = vim.api.nvim_buf_get_name(0)
      local workspace_root = find_workspace_root(filepath)
      if workspace_root then
        setup_roslyn_lsp(workspace_root)
      else
        vim.notify("No .sln or .csproj found for current file", vim.log.levels.WARN)
      end
      
    elseif subcommand == 'stop' then
      -- Use native LSP API to find roslyn client
      local clients = vim.lsp.get_clients({ name = 'roslyn' })
      
      if #clients > 0 then
        local client = clients[1]
        vim.lsp.stop_client(client.id, true)
        roslyn_client_id = nil
        vim.notify("Stopped Roslyn Language Service", vim.log.levels.INFO)
      else
        vim.notify("No Roslyn Language Service instance running", vim.log.levels.WARN)
      end
      
    elseif subcommand == 'status' then
      -- Use native LSP API to get all clients and find roslyn
      local clients = vim.lsp.get_clients({ name = 'roslyn' })
      
      if #clients > 0 then
        local client = clients[1]
        local buffers = vim.lsp.get_buffers_by_client_id(client.id)
        local buf_count = #buffers
        local root = client.config.root_dir or "unknown"
        
        -- Update our tracking variable
        roslyn_client_id = client.id
        
        vim.notify(string.format(
          "Roslyn Language Service\n  Status: Running\n  Client ID: %d\n  Attached buffers: %d\n  Workspace root: %s",
          client.id, buf_count, root
        ), vim.log.levels.INFO)
      else
        vim.notify("Roslyn Language Service is not running", vim.log.levels.INFO)
      end
      
    elseif subcommand == 'solution' then
      local filepath = vim.api.nvim_buf_get_name(0)
      local workspace_root = find_workspace_root(filepath)
      if workspace_root then
        vim.notify("Workspace root: " .. workspace_root, vim.log.levels.INFO)
      else
        vim.notify("No .sln or .csproj found for current file", vim.log.levels.WARN)
      end
      
    else
      vim.notify("Roslyn: Unknown subcommand '" .. (subcommand or "") .. "'\nAvailable: start, stop, restart, status, solution", vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function()
      return { 'start', 'stop', 'restart', 'status', 'solution' }
    end,
    desc = "Manage Roslyn Language Service"
  })
end

-- Return empty table since this is not a plugin spec anymore
return {}
