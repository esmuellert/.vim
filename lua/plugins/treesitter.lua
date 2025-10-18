-- Treesitter configuration
-- Note: Neovim 0.12-dev has built-in treesitter support
-- Updated parsers are installed via install-deps-linux.sh to ~/.local/share/nvim/site/parser/

return {
  ------------------------------------------------------------------------
  -- 🌲 nvim-treesitter: Advanced syntax highlighting
  ------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
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

          -- Additional regex-based highlighting
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
}
