-- Treesitter configuration

local enabled = require('config.plugins-enabled')
-- Note: Neovim 0.12-dev has built-in treesitter support

-- Updated parsers are installed via install-deps-linux.sh to ~/.local/share/nvim/site/parser/



return {
  ------------------------------------------------------------------------
  -- 🌲 nvim-treesitter: Advanced syntax highlighting
  ------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = enabled.treesitter,
    event = 'BufRead',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        -- A list of parser names, or "all"
        ensure_installed = {
          "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline",
          "javascript", "typescript", "c_sharp", "powershell", "tsx",
          "html", "json", "python", "bash"
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        highlight = {
          enable = true,

          -- Disable for very large files (prevents hanging)
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,

          -- Additional regex-based highlighting
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
          -- Disable indent for problematic languages
          disable = {},
        },
      })
      
      -- Add timeout protection for treesitter parsing
      vim.g.ts_highlight_timeout = 500  -- 500ms timeout per tree
    end,
  },
}
