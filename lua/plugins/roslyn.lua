-- roslyn.nvim configuration for C# development

local enabled = require('config.plugins-enabled')

-- Helper function to install roslyn via Mason if not present
local function ensure_roslyn_installed()
  local mason_registry = require('mason-registry')
  
  if not mason_registry.is_installed('roslyn') then
    vim.notify("Installing roslyn language server...", vim.log.levels.INFO)
    local roslyn = mason_registry.get_package('roslyn')
    roslyn:install():once('closed', function()
      if roslyn:is_installed() then
        vim.notify("Roslyn installed successfully! Please restart Neovim.", vim.log.levels.INFO)
      else
        vim.notify("Failed to install roslyn. Please run :MasonInstall roslyn manually.", vim.log.levels.ERROR)
      end
    end)
  end
end

return {
  ------------------------------------------------------------------------
  -- 🔷 roslyn.nvim: Modern C# LSP using Roslyn language server
  ------------------------------------------------------------------------
  {
    'seblj/roslyn.nvim',
    enabled = enabled.lsp,
    ft = { 'cs' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    opts = function()
      return {
        filewatching = "auto",
        
        broad_search = true,
        
        lock_target = false,
        
        silent = false,
      }
    end,
    config = function(_, opts)
      -- Auto-install roslyn if not present
      vim.schedule(function()
        ensure_roslyn_installed()
      end)
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      require('roslyn').setup(opts)
      
      vim.lsp.config('roslyn', {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
        settings = {
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
    end,
  },
}
