-- Telescope fuzzy finder
--
-- SEARCH OPERATORS (via fzf-native):
--   'text  → Exact match       ^text  → Starts with
--   text$  → Ends with         !text  → Exclude (NOT)
--   one|two → OR operator
--
-- Examples:
--   'TODO        → Exact "TODO" only
--   ^src/        → Files in src directory
--   .lua$        → Files ending with .lua
--   !test        → Exclude files with "test"
--   ^src/ .ts$   → TypeScript files in src/
--
-- See TELESCOPE_SEARCH_MODES.md for full guide!

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  -- 🔭 telescope.nvim: Fuzzy finder and picker for Neovim
  ------------------------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    enabled = enabled.telescope,
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
      { '<leader>p', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>f', '<cmd>Telescope live_grep<cr>', desc = 'Live grep' },
      { '<leader>b', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
      { '<leader>hp', '<cmd>Telescope help_tags<cr>', desc = 'Help tags' },
      { '<leader>d', '<cmd>Telescope diagnostics<cr>', desc = 'Diagnostics' },
      { '<leader>hl', '<cmd>Telescope highlights<cr>', desc = 'Highlights' },
      { '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = 'Fuzzy find in buffer' },
      { '<leader>r', '<cmd>Telescope oldfiles<cr>', desc = 'Recent files' },
    },
    config = function()
      local actions = require('telescope.actions')
      local telescope = require('telescope')

      telescope.setup({
        defaults = {
          -- Better performance with ripgrep
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--glob=!**/.git/*', -- Exclude .git directory specifically
          },

          -- Improved file ignore patterns (Lua patterns, not shell globs)
          file_ignore_patterns = {
            '%.git/', -- Ignore .git/ directory but not git.lua files
            'node_modules/',
            '%.npm/',
            '%.cache/',
            '%.vscode/',
            '%.idea/',
            '__pycache__/',
            '%.py[cod]',
            '%.dll',
            '%.exe',
            '%.so',
            '%.dylib',
            '%.zip',
            '%.tar%.gz',
            '%.jpg',
            '%.jpeg',
            '%.png',
            '%.svg',
            '%.otf',
            '%.ttf',
          },

          -- Better layout
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              prompt_position = 'top',
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },

          -- Better sorting
          sorting_strategy = 'ascending',

          -- Better UI
          borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },

          -- Show helpful prompt to remind users of search operators
          prompt_prefix = '🔭 ',
          selection_caret = '❯ ',
          entry_prefix = '  ',

          -- Performance improvements
          path_display = { 'truncate' },
          dynamic_preview_title = true,

          -- Speed optimizations
          cache_picker = {
            num_pickers = 10, -- Cache last 10 pickers for instant re-open
          },
          file_previewer = require('telescope.previewers').vim_buffer_cat.new,
          grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
          qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

          mappings = {
            i = {
              ['<C-e>'] = { '<esc>', type = 'command' },
              ['<esc>'] = actions.close,
              ['<C-s>'] = actions.select_vertical,
              ['<C-x>'] = actions.select_horizontal,
              ['<C-n>'] = actions.cycle_history_next,
              ['<C-p>'] = actions.cycle_history_prev,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-u>'] = actions.preview_scrolling_up,
              ['<C-d>'] = actions.preview_scrolling_down,
              ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
              ['<C-/>'] = 'which_key', -- Show help for keybindings
            },
            n = {
              ['q'] = actions.close,
              ['<C-s>'] = actions.select_vertical,
              ['<C-x>'] = actions.select_horizontal,
              ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
            },
          },
        },

        pickers = {
          find_files = {
            hidden = true,
            -- Use fd if available (2-3x faster than rg for file finding)
            -- Falls back to rg if fd is not installed
            find_command = vim.fn.executable('fd') == 1 and { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' }
              or { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
            mappings = {
              n = {
                ['cd'] = function(prompt_bufnr)
                  local selection = require('telescope.actions.state').get_selected_entry()
                  local dir = vim.fn.fnamemodify(selection.path, ':p:h')
                  require('telescope.actions').close(prompt_bufnr)
                  vim.cmd(string.format('silent lcd %s', dir))
                end,
              },
            },
          },

          live_grep = {
            -- Optimized for speed: ripgrep is already the fastest
            additional_args = function()
              return { '--hidden', '--glob', '!**/.git/*' }
            end,
            -- Reduce initial file count for faster startup
            max_results = 10000,
          },

          buffers = {
            ignore_current_buffer = true,
            sort_lastused = true,
            sort_mru = true,
            theme = 'dropdown',
            previewer = false,
            mappings = {
              i = {
                ['<c-d>'] = actions.delete_buffer,
              },
              n = {
                ['dd'] = actions.delete_buffer,
              },
            },
          },

          oldfiles = {
            only_cwd = true,
          },

          current_buffer_fuzzy_find = {
            theme = 'dropdown',
            previewer = false,
          },
        },

        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      })

      -- Load fzf extension for better performance
      pcall(telescope.load_extension, 'fzf')
    end,
  },
}
