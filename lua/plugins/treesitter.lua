-- Treesitter configuration

local enabled = require('config.plugins-enabled')
-- Note: nvim-treesitter main branch requires Neovim 0.11.0+ (nightly)
-- Breaking changes from master branch: new API, manual parser installation required

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
      -- Setup is optional - only needed if you want to customize install_dir
      require('nvim-treesitter').setup({
        install_dir = vim.fn.stdpath('data') .. '/site',
      })

      -- Install parsers only if missing
      local parsers = {
        'c', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline',
        'javascript', 'typescript', 'c_sharp', 'powershell', 'tsx',
        'html', 'json', 'python', 'bash'
      }
      
      local missing = {}
      for _, parser in ipairs(parsers) do
        if not vim.treesitter.language.add(parser, { silent = true }) then
          table.insert(missing, parser)
        end
      end
      
      if #missing > 0 then
        require('nvim-treesitter').install(missing)
      end

      -- Enable highlighting via autocommand (new API)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'c', 'lua', 'vim', 'markdown', 'javascript', 'typescript',
          'typescriptreact', 'cs', 'powershell', 'html', 'json', 'python', 'bash', 'sh'
        },
        callback = function()
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
          if ok and stats and stats.size > max_filesize then
            return -- Skip large files
          end
          vim.treesitter.start()
        end,
        group = vim.api.nvim_create_augroup('TreesitterHighlight', { clear = true }),
      })

      -- Enable folding (optional)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'c', 'lua', 'vim', 'markdown', 'javascript', 'typescript',
          'typescriptreact', 'cs', 'powershell', 'html', 'json', 'python', 'bash', 'sh'
        },
        callback = function()
          vim.wo.foldmethod = 'expr'
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
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
