-- Telescope fuzzy finder

return {
  ------------------------------------------------------------------------
  -- 🔭 telescope.nvim: Fuzzy finder and picker for Neovim
  ------------------------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
      },
    },
    cmd = 'Telescope',
    keys = {
      { '<leader>p',  '<cmd>Telescope find_files<cr>',                                 desc = 'Find files' },
      { '<leader>f',  '<cmd>Telescope live_grep<cr>',                                  desc = 'Live grep' },
      { '<leader>b',  '<cmd>Telescope buffers<cr>',                                    desc = 'Buffers' },
      { '<leader>hp', '<cmd>Telescope help_tags<cr>',                                  desc = 'Help tags' },
      { '<leader>d',  '<cmd>Telescope diagnostics<cr>',                                desc = 'Diagnostics' },
      { '<leader>hl', '<cmd>Telescope highlights<cr>',                                 desc = 'Highlights' },
      { '<leader>pd', function() vim.fn.feedkeys(":Telescope find_files cwd=", "n") end, desc = 'Find files in directory' },
      { '<leader>fd', function() vim.fn.feedkeys(":Telescope live_grep cwd=", "n") end,  desc = 'Live grep in directory' },
    },
    config = function()
      local actions = require("telescope.actions")
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
          },
          file_ignore_patterns = { 'node_modules', '.git' },
          mappings = {
            i = {
              ["<C-e>"] = { "<esc>", type = "command" },
              ["<esc>"] = actions.close,
              ["<C-s>"] = actions.select_vertical,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/**', '--glob', '!**/node_modules/**' },
            mappings = {
              n = {
                ["cd"] = function(prompt_bufnr)
                  local selection = require("telescope.actions.state").get_selected_entry()
                  local dir = vim.fn.fnamemodify(selection.path, ":p:h")
                  require("telescope.actions").close(prompt_bufnr)
                  vim.cmd(string.format("silent lcd %s", dir))
                end
              }
            }
          },
          buffers = {
            ignore_current_buffer = true,
            sort_lastused = true,
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer,
              },
              n = {
                ["<c-d>"] = actions.delete_buffer,
              }
            }
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })

      pcall(telescope.load_extension, 'fzf')
    end,
  },
}
