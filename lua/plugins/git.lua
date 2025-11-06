-- Git-related plugins

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  -- 🚀 Fugitive: The premier Git plugin for Vim/Neovim
  ------------------------------------------------------------------------
  {
    'tpope/vim-fugitive',
    enabled = enabled.fugitive,
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Ggrep', 'GMove', 'GDelete', 'GBrowse', 'GRemove', 'GRename' },
    -- keys = {
    --   { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
    --   { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git commit' },
    --   { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
    --   { '<leader>gP', '<cmd>Git pull<cr>', desc = 'Git pull' },
    --   { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
    --   { '<leader>gd', '<cmd>Gdiffsplit<cr>', desc = 'Git diff split' },
    --   { '<leader>gl', '<cmd>Git log<cr>', desc = 'Git log' },
    --   { '<leader>gL', '<cmd>Git log --oneline --graph --all<cr>', desc = 'Git log graph' },
    --   { '<leader>gw', '<cmd>Gwrite<cr>', desc = 'Git write (stage)' },
    --   { '<leader>gr', '<cmd>Gread<cr>', desc = 'Git read (checkout)' },
    -- },
    config = function()
      -- Automatically delete fugitive buffers when they become hidden
      vim.api.nvim_create_autocmd('BufReadPost', {
        pattern = 'fugitive://*',
        callback = function()
          vim.bo.bufhidden = 'delete'
        end,
      })

      -- Set up nice statusline integration
      vim.api.nvim_create_autocmd('User', {
        pattern = 'FugitiveChanged',
        callback = function()
          vim.cmd('redrawstatus')
        end,
      })
    end,
  },

  ------------------------------------------------------------------------
  -- 🔍 Gitsigns: Track git changes in the gutter
  ------------------------------------------------------------------------
  {
    'lewis6991/gitsigns.nvim',
    enabled = enabled.gitsigns,
    event = 'BufRead',
    opts = function()
      return {
        signs = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '┃' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
          delay = 1500, -- Increased delay to avoid race conditions during file reloads
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true, -- Use focus events (more reliable window state)
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end)

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end)
          map('n', '<leader>hk', gitsigns.preview_hunk_inline)
          map('n', '<leader>hkrs', gitsigns.reset_hunk)
        end,
      }
    end,
  },

  ------------------------------------------------------------------------
  -- 🔄 Diffview: Visualize and manage git diffs
  ------------------------------------------------------------------------
  {
    'sindrets/diffview.nvim',
    enabled = enabled.diffview,
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
    keys = {
      {
        '<leader>df',
        function()
          if next(require('diffview.lib').views) == nil then
            vim.cmd('DiffviewOpen')
          else
            vim.cmd('DiffviewClose')
          end
        end,
        desc = 'Toggle Diffview',
      },
    },
    config = function()
      local actions = require('diffview.actions')

      require('diffview').setup({
        -- Enhanced diff highlighting - makes additions/deletions more visible
        enhanced_diff_hl = true,

        -- Show icons for files (requires nvim-web-devicons)
        use_icons = true,

        -- Show helpful hints at the bottom
        show_help_hints = true,

        -- Icons configuration
        icons = {
          folder_closed = '',
          folder_open = '',
        },
        signs = {
          fold_closed = '',
          fold_open = '',
          done = '✓',
        },

        -- View configuration
        view = {
          default = {
            layout = 'diff2_horizontal', -- Side-by-side diff
            winbar_info = false,
          },
          merge_tool = {
            layout = 'diff3_horizontal',
            disable_diagnostics = true,
            winbar_info = true,
          },
          file_history = {
            layout = 'diff2_horizontal',
            winbar_info = false,
          },
        },

        -- File panel configuration
        file_panel = {
          listing_style = 'tree', -- Tree view like the example
          tree_options = {
            flatten_dirs = true, -- Flatten dirs with single child
            folder_statuses = 'only_folded', -- Show folder status only when folded
          },
          win_config = {
            position = 'left',
            width = 35,
            win_opts = {},
          },
        },

        -- File history panel configuration
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = 'combined',
              },
              multi_file = {
                diff_merges = 'first-parent',
              },
            },
          },
          win_config = {
            position = 'bottom',
            height = 16,
            win_opts = {},
          },
        },

        -- Keymaps
        keymaps = {
          disable_defaults = false,
          view = {
            -- Navigate between files
            { 'n', '<tab>', actions.select_next_entry, { desc = 'Next file' } },
            { 'n', '<s-tab>', actions.select_prev_entry, { desc = 'Previous file' } },
            { 'n', '[F', actions.select_first_entry, { desc = 'First file' } },
            { 'n', ']F', actions.select_last_entry, { desc = 'Last file' } },

            -- File operations
            { 'n', 'gf', actions.goto_file_edit, { desc = 'Open file' } },
            { 'n', '<C-w>gf', actions.goto_file_tab, { desc = 'Open file in new tab' } },

            -- Panel operations
            { 'n', '<leader>e', actions.focus_files, { desc = 'Focus file panel' } },
            { 'n', '<leader>b', actions.toggle_files, { desc = 'Toggle file panel' } },

            -- Layout
            { 'n', 'g<C-x>', actions.cycle_layout, { desc = 'Cycle layout' } },

            -- Revert/Obtain changes (use vim's diff commands)
            { 'n', 'do', '<cmd>diffget<cr>', { desc = 'Obtain diff (revert line)' } },
            { 'n', 'dp', '<cmd>diffput<cr>', { desc = 'Put diff (apply line)' } },

            -- Conflict resolution (for merge tool)
            { 'n', '[x', actions.prev_conflict, { desc = 'Previous conflict' } },
            { 'n', ']x', actions.next_conflict, { desc = 'Next conflict' } },
            { 'n', '<leader>co', actions.conflict_choose('ours'), { desc = 'Choose OURS' } },
            { 'n', '<leader>ct', actions.conflict_choose('theirs'), { desc = 'Choose THEIRS' } },
            { 'n', '<leader>cb', actions.conflict_choose('base'), { desc = 'Choose BASE' } },
            { 'n', '<leader>ca', actions.conflict_choose('all'), { desc = 'Choose ALL' } },
            { 'n', 'dx', actions.conflict_choose('none'), { desc = 'Delete conflict' } },
          },
          file_panel = {
            -- Navigation
            { 'n', 'j', actions.next_entry, { desc = 'Next entry' } },
            { 'n', 'k', actions.prev_entry, { desc = 'Previous entry' } },
            { 'n', '<cr>', actions.select_entry, { desc = 'Open diff' } },
            { 'n', 'o', actions.select_entry, { desc = 'Open diff' } },
            { 'n', 'l', actions.select_entry, { desc = 'Open diff' } },
            { 'n', '<2-LeftMouse>', actions.select_entry, { desc = 'Open diff' } },

            -- Staging (works when comparing against index)
            { 'n', '-', actions.toggle_stage_entry, { desc = 'Stage/unstage' } },
            { 'n', 's', actions.toggle_stage_entry, { desc = 'Stage/unstage' } },
            { 'n', 'S', actions.stage_all, { desc = 'Stage all' } },
            { 'n', 'U', actions.unstage_all, { desc = 'Unstage all' } },

            -- File operations
            { 'n', 'X', actions.restore_entry, { desc = 'Restore file' } },
            { 'n', 'R', actions.refresh_files, { desc = 'Refresh' } },

            -- Tree operations
            { 'n', 'zo', actions.open_fold, { desc = 'Expand fold' } },
            { 'n', 'zc', actions.close_fold, { desc = 'Collapse fold' } },
            { 'n', 'h', actions.close_fold, { desc = 'Collapse fold' } },
            { 'n', 'za', actions.toggle_fold, { desc = 'Toggle fold' } },
            { 'n', 'zR', actions.open_all_folds, { desc = 'Expand all' } },
            { 'n', 'zM', actions.close_all_folds, { desc = 'Collapse all' } },

            -- View switching
            { 'n', 'i', actions.listing_style, { desc = 'Toggle list/tree' } },
            { 'n', 'f', actions.toggle_flatten_dirs, { desc = 'Flatten dirs' } },

            -- Help
            { 'n', 'g?', actions.help('file_panel'), { desc = 'Help' } },
          },
          file_history_panel = {
            { 'n', 'g!', actions.options, { desc = 'Options' } },
            { 'n', 'y', actions.copy_hash, { desc = 'Copy hash' } },
            { 'n', 'L', actions.open_commit_log, { desc = 'Commit details' } },
            { 'n', 'X', actions.restore_entry, { desc = 'Restore file' } },
            { 'n', '<cr>', actions.select_entry, { desc = 'Open diff' } },
            { 'n', 'o', actions.select_entry, { desc = 'Open diff' } },
            { 'n', 'g?', actions.help('file_history_panel'), { desc = 'Help' } },
          },
        },

        -- Hooks for customization
        hooks = {
          diff_buf_read = function()
            -- Improve diff readability
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.relativenumber = false
          end,
        },
      })
    end,
  },
}
