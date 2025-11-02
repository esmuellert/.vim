-- Treesitter configuration

local enabled = require('config.plugins-enabled')
-- Note: nvim-treesitter main branch requires Neovim 0.11.0+ (nightly)
-- Breaking changes from master branch: new API, manual parser installation required
-- Install parsers manually with: :TSInstall c lua vim vimdoc markdown markdown_inline javascript typescript c_sharp powershell tsx html json python bash http

return {
  ------------------------------------------------------------------------
  -- 🌲 nvim-treesitter: Advanced syntax highlighting
  ------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = enabled.treesitter,
    lazy = false, -- Plugin should not be lazy-loaded per documentation
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      -- Note: setup() is optional - only needed for non-default install_dir
      -- Default install_dir is stdpath('data')/site, so we don't need to call setup()

      -- Enable highlighting via autocommand (new API)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'c', 'lua', 'vim', 'markdown', 'javascript', 'typescript',
          'typescriptreact', 'cs', 'powershell', 'html', 'json', 'python', 'bash', 'sh', 'http'
        },
        callback = function()
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
          if ok and stats and stats.size > max_filesize then
            return -- Skip large files
          end
          vim.treesitter.start()
          -- Ensure LSP semantic tokens have higher priority than treesitter
          vim.highlight.priorities.semantic_tokens = 125
          vim.highlight.priorities.treesitter = 100
        end,
        group = vim.api.nvim_create_augroup('TreesitterHighlight', { clear = true }),
      })

      -- Enable folding (optional)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'c', 'lua', 'vim', 'markdown', 'javascript', 'typescript',
          'typescriptreact', 'cs', 'powershell', 'html', 'json', 'python', 'bash', 'sh', 'http'
        },
        callback = function()
          vim.wo.foldmethod = 'expr'
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo.foldlevel = 99 -- Open all folds by default
        end,
        group = vim.api.nvim_create_augroup('TreesitterFold', { clear = true }),
      })

      -- Enable experimental indentation (optional)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'lua', 'python', 'javascript', 'typescript' },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
        group = vim.api.nvim_create_augroup('TreesitterIndent', { clear = true }),
      })
    end,
  },
}
