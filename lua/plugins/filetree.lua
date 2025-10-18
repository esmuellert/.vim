-- File tree explorer

return {
  ------------------------------------------------------------------------
  --- 🌲 nvim-tree.lua: File explorer tree
  ------------------------------------------------------------------------
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile' },
    keys = {
      { '<leader>E', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle NvimTree' },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        git = {
          timeout = 10000
        },
        renderer = {
          icons = {
            glyphs = {
              git = {
                unstaged = "󱧃",
                staged = "󰸩",
                untracked = ""
              }
            }
          }
        }
      })

      -- Auto-close nvim-tree when it's the last window
      vim.api.nvim_create_autocmd("BufEnter", {
        nested = true,
        callback = function()
          if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
            vim.cmd "quit"
          end
        end
      })
    end,
  },
}
