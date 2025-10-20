-- File tree explorer

local enabled = require('config.plugins-enabled')


return {
  ------------------------------------------------------------------------
  --- 🌲 nvim-tree.lua: File explorer tree (DISABLED)
  ------------------------------------------------------------------------
  {
    enabled = enabled.nvim_tree,
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

  ------------------------------------------------------------------------
  --- 🌳 neo-tree.nvim: Modern file explorer tree
  ------------------------------------------------------------------------
  {
    enabled = enabled.neo_tree,
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    cmd = { 'Neotree' },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'Toggle Neo-tree' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,

        default_component_configs = {
          indent = {
            padding = 0,
            with_markers = true,
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            default = "",
          },
          git_status = {
            symbols = {
              added     = "",
              modified  = "",
              deleted   = "✖",
              renamed   = "󰁕",
              untracked = "",
              ignored   = "",
              unstaged  = "󱧃",
              staged    = "󰸩",
              conflict  = "",
            }
          },
        },

        window = {
          position = "left",
          width = 30,
          mappings = {
            ["<space>"] = "none",
            ["<cr>"] = "open",
            ["<esc>"] = "cancel",
            ["l"] = "open",
            ["h"] = "close_node",
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
            ["a"] = { "add", config = { show_path = "relative" } },
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["R"] = "refresh",
            ["?"] = "show_help",
          },
        },

        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = true,
          },
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },

        git_status = {
          window = {
            position = "float",
          },
        },
      })
    end,
  },
}
