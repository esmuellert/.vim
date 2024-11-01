local vimrc_path = vim.fn.stdpath('config') .. '/vimrc'
vim.cmd('source ' .. vimrc_path)

------------------------------------------------------------------------
--- Custom utility functions and configuration for NeoVim
------------------------------------------------------------------------
--- Check if the current OS is Windows
function is_windows()
  return vim.loop.os_uname().sysname == 'Windows_NT'
end

--- Check if path exists
function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

--- Set spell check
vim.cmd('setlocal spell spelllang=en_us')

--- Set the sign column to always be visible
vim.opt.signcolumn = 'yes'

--- Github color palette
local github_colors = {
  black = "#24292e",
  white = "#ffffff",
  gray = { "#fafbfc", "#f6f8fa", "#e1e4e8", "#d1d5da", "#959da5", "#6a737d", "#586069", "#444d56", "#2f363d", "#24292e" },
  blue = { "#f1f8ff", "#dbedff", "#c8e1ff", "#79b8ff", "#2188ff", "#0366d6", "#005cc5", "#044289", "#032f62", "#05264c" },
  green = { "#f0fff4", "#dcffe4", "#bef5cb", "#85e89d", "#34d058", "#28a745", "#22863a", "#176f2c", "#165c26", "#144620" },
  yellow = { "#fffdef", "#fffbdd", "#fff5b1", "#ffea7f", "#ffdf5d", "#ffd33d", "#f9c513", "#dbab09", "#b08800", "#735c0f" },
  orange = { "#fff8f2", "#ffebda", "#ffd1ac", "#ffab70", "#fb8532", "#f66a0a", "#e36209", "#d15704", "#c24e00", "#a04100" },
  red = { "#ffeef0", "#ffdce0", "#fdaeb7", "#f97583", "#ea4a5a", "#d73a49", "#cb2431", "#b31d28", "#9e1c23", "#86181d" },
  purple = { "#f5f0ff", "#e6dcfd", "#d1bcf9", "#b392f0", "#8a63d2", "#6f42c1", "#5a32a3", "#4c2889", "#3a1d6e", "#29134e" },
  pink = { "#ffeef8", "#fedbf0", "#f9b3dd", "#f692ce", "#ec6cb9", "#ea4aaa", "#d03592", "#b93a86", "#99306f", "#6d224f" }
}
------------------------------------------------------------------------
-- ⌨️ Custom Shortcuts
------------------------------------------------------------------------
--- Prettier format current buffer
vim.api.nvim_set_keymap('n', '<A-S-F>', ':w!<CR> :!pnpm exec prettier --write %<CR> :edit!<CR>',
  { noremap = true, silent = true })

-- Function to toggle terminal buffer
function ToggleTerminal()
  -- Find the terminal buffer
  local term_buf = vim.fn.bufnr('term://*')

  if term_buf ~= -1 then
    -- Get the window number where the terminal buffer is displayed
    local term_win = vim.fn.bufwinnr(term_buf)

    if term_win ~= -1 then
      -- If the terminal is visible, hide the tab (close the tab)
      vim.cmd('tabclose')
    else
      -- If the terminal exists but is not visible, switch to it in a new tab
      vim.cmd('tabnew | buffer ' .. term_buf)
    end
  else
    -- If no terminal exists, open a new terminal in a new tab
    vim.cmd('tabnew | terminal')
    -- Automatically enter insert mode and hide line numbers
    vim.cmd('startinsert')
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
end

-- Map <leader>T to toggle terminal
vim.api.nvim_set_keymap('n', '<leader>t', ':lua ToggleTerminal()<CR>', { noremap = true, silent = true })

-- Function to toggle LazyGit
function ToggleLazyGit()
  -- Find the terminal buffer running LazyGit
  local term_buf = vim.fn.bufnr('term://*lazygit')

  if term_buf ~= -1 then
    -- Get the window number of the terminal buffer
    local term_win = vim.fn.bufwinnr(term_buf)

    if term_win ~= -1 then
      -- If the terminal is visible, switch to its tab
      vim.cmd('tabnew | buffer ' .. term_buf)
      vim.cmd('startinsert')
    else
      -- If the terminal exists but isn't visible, open it in a new tab
      vim.cmd('tabnew | buffer ' .. term_buf)
      vim.cmd('startinsert')
    end
  else
    -- If LazyGit is not running, check if it's installed
    if vim.fn.executable('lazygit') == 1 then
      -- Open LazyGit in a new tab
      vim.cmd('tabnew | terminal lazygit')
      vim.cmd('startinsert')

      -- Hide line numbers for the terminal window
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false

      -- Automatically exit insert mode when LazyGit closes
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = 0, -- Current buffer
        callback = function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        end,
      })
    else
      print("LazyGit is not installed or not found in PATH.")
    end
  end
end

-- Map <leader>g to toggle LazyGit
vim.api.nvim_set_keymap('n', '<leader>g', ':lua ToggleLazyGit()<CR>', { noremap = true, silent = true })

------------------------------------------------------------------------
--- 💤 lazynvim: A lightweight and optimized Neovim configuration for lazy loading
------------------------------------------------------------------------
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load local plugin settings
local local_plugin_path = vim.fn.stdpath('config') .. '/lua/plugin/local.lua'
local local_plugin_specs = {}
if vim.loop.fs_stat(local_plugin_path) then
  local_plugin_specs = require("plugin.local")
end

-- Setup lazy.nvim
require("lazy").setup({
  spec = vim.list_extend({
    -- add your plugins here

    ------------------------------------------------------------------------
    --- 🌿 lush.nvim: A Neovim plugin for building and customizing themes with ease
    ------------------------------------------------------------------------
    {
      'rktjmp/lush.nvim',
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd('colorscheme github_light')
      end,
    },

    ------------------------------------------------------------------------
    -- 🔭 telescope.nvim: Fuzzy finder and picker for Neovim
    ------------------------------------------------------------------------
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
      },
      keys = {
        { '<leader>p',  function() require('telescope.builtin').find_files() end,          desc = 'Telescope find files' },
        { '<leader>f',  function() require('telescope.builtin').live_grep() end,           desc = 'Telescope live grep' },
        { '<leader>b',  function() require('telescope.builtin').buffers() end,             desc = 'Telescope buffers' },
        { '<leader>hp', function() require('telescope.builtin').help_tags() end,           desc = 'Telescope help tags' },
        { '<leader>pd', function() vim.fn.feedkeys(":Telescope find_files cwd=", "n") end, desc = 'Telescope find files with custom cwd' },
        { '<leader>fd', function() vim.fn.feedkeys(":Telescope live_grep cwd=", "n") end,  desc = 'Telescope live grep with custom cwd' },
        { '<leader>d',  function() require('telescope.builtin').diagnostics() end,         desc = 'Telescope diagnostics' },
        { '<leader>hl', function() require('telescope.builtin').highlights() end,          desc = 'Telescope highlights' },
      },
      opts = function()
        local actions = require('telescope.actions')
        return {
          defaults = {
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
                  end,
                },
              },
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
                },
              },
            },
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
          },
        }
      end,
      config = function(_, opts)
        local telescope = require('telescope')
        telescope.setup(opts)
        pcall(telescope.load_extension, 'fzf')
      end,
    },
    ------------------------------------------------------------------------
    -- 🌲 treesitter configuration 🌲
    ------------------------------------------------------------------------
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      opts = function()
        return {
          -- A list of parser names, or "all"
          ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline", "javascript", "typescript", "c_sharp", "powershell", "tsx", "html", "json" },

          -- Install parsers synchronously (only applied to `ensure_installed`)
          sync_install = false,

          -- Automatically install missing parsers when entering buffer
          auto_install = true,

          -- List of parsers to ignore installing (or "all")
          -- ignore_install = { "javascript" },

          highlight = {
            enable = true,

            -- List of languages that will be disabled
            disable = { "javascript", "typescript", "tsx" },

            -- Additional regex-based highlighting
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        }
      end,
    },
    ------------------------------------------------------------------------
    -- 🔍 Gitsigns configuration: track git changes in the gutter
    ------------------------------------------------------------------------
    {
      'lewis6991/gitsigns.nvim',
      opts = function()
        return {
          signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '┃' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
          },
          signs_staged = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
          },
          signs_staged_enable = true,
          signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
          numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
          linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
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
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
          },
          current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
          sign_priority = 6,
          update_debounce = 100,
          status_formatter = nil,  -- Use default
          max_file_length = 40000, -- Disable if file is longer than this (in lines)
          preview_config = {
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

            -- Custom mapping
            map('n', '<leader>hk', gitsigns.preview_hunk_inline)
            map('n', '<leader>hkrs', gitsigns.reset_hunk)
          end,
        }
      end,
    },

    ------------------------------------------------------------------------
    -- 🔄 Diffview configuration: visualize and manage git diffs
    ------------------------------------------------------------------------
    {
      'sindrets/diffview.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
      },
      opts = function()
        return {
          enhanced_diff_hl = true,
        }
      end,
      config = function(_, opts)
        require("diffview").setup(opts)

        -- Custom key mapping for toggling Diffview
        vim.keymap.set('n', '<leader>df', function()
          if next(require('diffview.lib').views) == nil then
            vim.cmd('DiffviewOpen')
          else
            vim.cmd('DiffviewClose')
          end
        end, { desc = 'Toggle Diffview' })
      end,
    },

    ------------------------------------------------------------------------
    -- 📏 indent-blankline.nvim: Visual indentation guides for Neovim
    ------------------------------------------------------------------------
    {
      'lukas-reineke/indent-blankline.nvim', -- Replace 'ibl' with the appropriate plugin name
      main = "ibl",
      opts =
      {
        indent = {
          char = "│",
          tab_char = { "│" },
        },
      }
    },

    ------------------------------------------------------------------------
    -- 💬 Comment.nvim: Efficient code commenting for Neovim
    ------------------------------------------------------------------------
    { 'numToStr/Comment.nvim', },

    ------------------------------------------------------------------------
    --- 📦 nvim-autopairs: Automatically insert pairs of delimiters
    ------------------------------------------------------------------------
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = true
    },

    ------------------------------------------------------------------------
    --- 📦 nvim-cmp: Autocompletion plugin for Neovim
    ------------------------------------------------------------------------
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        -- 'hrsh7th/cmp-vsnip', -- Uncomment if using vsnip
        -- 'L3MON4D3/LuaSnip', -- Uncomment if using luasnip
        -- 'quangnguyen30192/cmp-nvim-ultisnips', -- Uncomment if using ultisnips
        -- 'dcampos/nvim-snippy', -- Uncomment if using snippy
      },
      opts = function()
        local cmp = require('cmp')
        return {
          snippet = {
            expand = function(args)
              -- Specify your snippet engine here:
              -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
              -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
              -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
              -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
              vim.snippet.expand(args.body) -- For native Neovim snippets (Neovim v0.10+)
            end,
          },
          window = {
            -- completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            -- { name = 'vsnip' }, -- Uncomment if using vsnip
            -- { name = 'luasnip' }, -- Uncomment if using luasnip
            -- { name = 'ultisnips' }, -- Uncomment if using ultisnips
            -- { name = 'snippy' }, -- Uncomment if using snippy
          }, {
            { name = 'buffer' },
          }),
        }
      end,
      config = function(_, opts)
        local cmp = require('cmp')
        cmp.setup(opts)

        -- Set configuration for specific filetypes
        -- Uncomment if using cmp-git
        --[[
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' },
        }, {
          { name = 'buffer' },
        })
      })
      require("cmp_git").setup()
      ]]

        -- Use buffer source for `/` and `?` in the command line
        cmp.setup.cmdline({ '/', '?' }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = 'buffer' }
          }
        })

        -- Use cmdline & path source for `:`
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          }),
          matching = { disallow_symbol_nonprefix_matching = false },
        })
      end,
    },

    ------------------------------------------------------------------------
    -- 🛠️ mason.nvim: Tool to manage LSPs, DAPs, linters, and formatters
    ------------------------------------------------------------------------
    {
      'williamboman/mason-lspconfig.nvim',
      dependencies = {
        'williamboman/mason.nvim',
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp', -- For LSP capabilities
      },
      opts = function()
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        require('mason').setup({})
        return {
          ensure_installed = { 'ts_ls', 'html', 'cssls', 'lua_ls' },
          handlers = {
            function(server)
              require("lspconfig")[server].setup({
                capabilities = capabilities,
              })
            end,
            ['lua_ls'] = function(server)
              require("lspconfig")[server].setup({
                capabilities = capabilities,
                settings = {
                  Lua = {
                    diagnostics = {
                      globals = { 'vim' },
                    },
                  },
                },
              })
            end,
            ['ts_ls'] = function(server)
              require("lspconfig")[server].setup({
                root_dir = function(_, bufnr)
                  return vim.fs.root(bufnr, { '.git' })
                end,
                capabilities = capabilities,
                -- on_attach = function(client)
                --   client.server_capabilities.semanticTokensProvider = nil -- Disable semantic tokens
                -- end
              })
            end,
          },
        }
      end,
    },

    ------------------------------------------------------------------------
    --- 🚨 Trouble.nvim: A pretty list for showing diagnostics
    ------------------------------------------------------------------------
    {
      "folke/trouble.nvim",
      opts = {}, -- for default options, refer to the configuration section for custom setup.
      cmd = "Trouble",
      keys = {
        {
          "<leader>xx",
          "<cmd>Trouble diagnostics toggle<cr>",
          desc = "Diagnostics (Trouble)",
        },
        {
          "<leader>xX",
          "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
          desc = "Buffer Diagnostics (Trouble)",
        },
        {
          "<leader>cs",
          "<cmd>Trouble symbols toggle focus=false<cr>",
          desc = "Symbols (Trouble)",
        },
        {
          "<leader>cl",
          "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
          desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
          "<leader>xL",
          "<cmd>Trouble loclist toggle<cr>",
          desc = "Location List (Trouble)",
        },
        {
          "<leader>xQ",
          "<cmd>Trouble qflist toggle<cr>",
          desc = "Quickfix List (Trouble)",
        },
      },
    },

    ------------------------------------------------------------------------
    --- 🛞 fidget.nvim: Standalone UI for LSP progress notifications
    ------------------------------------------------------------------------
    {
      "j-hui/fidget.nvim",
      opts = {}
    },

    ------------------------------------------------------------------------
    --- 🌀 lspsaga.nvim: A light-weight LSP UI with handy features
    ------------------------------------------------------------------------
    {
      'nvimdev/lspsaga.nvim',
      dependencies = {
        'neovim/nvim-lspconfig',
      },
      opts = function()
        return {
          ui = {
            code_action = '',
          },
        }
      end,
      keys = {
        {
          'gd',
          '<cmd>Lspsaga goto_definition<CR>',
          desc = 'Goto Definition',
          mode = 'n',
          noremap = true,
          silent = true
        },
        { 'gr',         '<cmd>Lspsaga finder<CR>',      desc = 'Lspsaga Finder',                 mode = 'n', noremap = true, silent = true },
        { 'gi',         '<cmd>Lspsaga finder imp<CR>',  desc = 'Lspsaga Finder Implementations', mode = 'n', noremap = true, silent = true },
        { 'K',          '<cmd>Lspsaga hover_doc<CR>',   desc = 'Hover Documentation',            mode = 'n', noremap = true, silent = true },
        { 'rn',         '<cmd>Lspsaga rename<CR>',      desc = 'Rename Symbol',                  mode = 'n', noremap = true, silent = true },
        { '<leader>ac', '<cmd>Lspsaga code_action<CR>', desc = 'Code Action',                    mode = 'n', noremap = true, silent = true },
        { '<leader>fm', vim.lsp.buf.format,             desc = 'Format Buffer',                  mode = 'n', noremap = true, silent = true },
      },
    },

    ------------------------------------------------------------------------
    --- 🌲 nvim-tree.lua: A file explorer tree for neovim
    ------------------------------------------------------------------------
    {
      'nvim-tree/nvim-tree.lua',
      dependencies = {
        'nvim-tree/nvim-web-devicons', -- optional, for file icons
      },
      opts = function()
        return {
          renderer = {
            icons = {
              glyphs = {
                git = {
                  unstaged = "󱧃",
                  staged = "󰸩",
                  untracked = "",
                },
              },
            },
          },
        }
      end,
      keys = {
        { '<leader>E', ':NvimTreeToggle<CR>', desc = 'Toggle Nvim Tree', mode = 'n', noremap = true, silent = true },
      },
      config = function(_, opts)
        require('nvim-tree').setup(opts)

        -- Auto close NvimTree if it's the last window open
        vim.api.nvim_create_autocmd("BufEnter", {
          nested = true,
          callback = function()
            if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
              vim.cmd "quit"
            end
          end,
        })
      end,
    },

    ------------------------------------------------------------------------
    --- 📑 bufferline.nvim: A snazzy buffer line for Neovim
    ------------------------------------------------------------------------
    {
      'akinsho/bufferline.nvim',
      version = "*",
      dependencies = 'nvim-tree/nvim-web-devicons',
      opts = {
        options = {
          mode = "tabs",
          indicator = {
            style = 'underline'
          }
        },
        highlights = {
          fill = {
            fg = github_colors.gray[2],
            bg = github_colors.gray[2],
          },
          background = {
            fg = github_colors.gray[6],
            bg = github_colors.gray[2],
          },
          buffer_selected = {
            fg = github_colors.gray[9],
            bg = github_colors.white,
          },
          tab_close = {
            fg = github_colors.gray[6],
            bg = github_colors.gray[2],
          },
          close_button = {
            fg = github_colors.gray[6],
            bg = github_colors.gray[2],
          },
          separator = {
            fg = github_colors.gray[2],
            bg = github_colors.gray[2],
          },
          modified = {
            fg = github_colors.gray[9],
            bg = github_colors.gray[2],
          },
        }
      }
    },

    ------------------------------------------------------------------------
    --- 📊 lualine.nvim: A blazing fast and easy-to-configure statusline
    ------------------------------------------------------------------------
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = function()
        local github_theme = {
          normal = {
            a = { fg = github_colors.gray[1], bg = github_colors.purple[3] },
            b = { fg = github_colors.gray[6], bg = github_colors.gray[3] },
            c = { fg = github_colors.gray[6], bg = github_colors.gray[2] },
          },

          insert = { a = { fg = github_colors.gray[1], bg = github_colors.blue[4] } },
          visual = { a = { fg = github_colors.gray[1], bg = github_colors.green[5] } },
          replace = { a = { fg = github_colors.gray[1], bg = github_colors.pink[4] } },

          inactive = {
            a = { fg = github_colors.gray[6], bg = github_colors.gray[3] },
            b = { fg = github_colors.gray[6], bg = github_colors.gray[3] },
            c = { fg = github_colors.gray[6], bg = github_colors.gray[1] },
          },
        }
        return {
          options = {
            theme = github_theme,
            component_separators = '',
            section_separators = { left = '', right = '' },
          },
          sections = {
            lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
            lualine_c = {
              {
                'filename',
                path = 1
              }
            },
            lualine_z = {
              { 'location', separator = { right = '' }, left_padding = 2 },
            },
          }
        }
      end
    },

    ------------------------------------------------------------------------
    --- 🎨 nvim-colorizer.lua: highlighter for Neovim
    ------------------------------------------------------------------------
    { 'norcalli/nvim-colorizer.lua' },

    ------------------------------------------------------------------------
    --- 🔑 which-key.nvim: displaying keybindings in a popup
    ------------------------------------------------------------------------
    { 'folke/which-key.nvim' },

    ------------------------------------------------------------------------
    --- 💡 vim-illuminate: highlighting matching words under the cursor
    ------------------------------------------------------------------------
    { 'RRethy/vim-illuminate' },

    ------------------------------------------------------------------------
    --- 🧹 nvim-eslint: A Neovim plugin for effortless ESLint integration
    ------------------------------------------------------------------------
    {
      'esmuellert/nvim-eslint',
      opts = {}
    }

  }, local_plugin_specs),


  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false },
})
