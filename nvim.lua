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
-- 🌲 treesitter configuration 🌲
------------------------------------------------------------------------
require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline", "javascript", "typescript", "c_sharp", "powershell", "tsx", "html", "json" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  --ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "javascript", "typescript", "tsx" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    -- disable = function(lang, buf)
    --    local max_filesize = 100 * 1024 -- 100 KB
    --    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    --    if ok and stats and stats.size > max_filesize then
    --        return true
    --    end
    -- end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  }
}

------------------------------------------------------------------------
-- 🔍 Gitsigns configuration: track git changes in the gutter
------------------------------------------------------------------------
require('gitsigns').setup {
  signs                        = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '┃' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged                 = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable          = true,
  signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir                 = {
    follow_files = true
  },
  auto_attach                  = true,
  attach_to_untracked          = false,
  current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts      = {
    virt_text = true,
    virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority                = 6,
  update_debounce              = 100,
  status_formatter             = nil,   -- Use default
  max_file_length              = 40000, -- Disable if file is longer than this (in lines)
  preview_config               = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  on_attach                    = function(bufnr)
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
  end
}

------------------------------------------------------------------------
-- 🔄 Diffview configuration: visualize and manage git diffs
------------------------------------------------------------------------
require("diffview").setup({
  enhanced_diff_hl = true
})

------------------------------------------------------------------------
-- 📏 indent-blankline.nvim: Visual indentation guides for Neovim
------------------------------------------------------------------------
require("ibl").setup {
  indent = {
    char = "│",
    tab_char = { "│" },
  },
}

------------------------------------------------------------------------
-- 🎨 github-nvim-theme: GitHub-inspired colors for Neovim
------------------------------------------------------------------------
-- require("github-theme").setup()

------------------------------------------------------------------------
-- 🔭 telescope.nvim: Fuzzy finder and picker for Neovim
------------------------------------------------------------------------
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>p', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>hp', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>pd',
  [[:lua require('telescope.builtin').find_files({ cwd = vim.fn.input("Enter directory: ", "", "dir") })<CR>]],
  { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fd',
  [[:lua require('telescope.builtin').live_grep({ cwd = vim.fn.input("Enter directory: ", "", "dir") })<CR>]],
  { noremap = true, silent = true })
vim.keymap.set('n', '<leader>d', builtin.diagnostics, { desc = 'Telescope diagnostics' })

-- Add devicons to telescope
-- Close telescope with <esc>
local actions = require("telescope.actions")


local telescope = require("telescope")
telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-s>"] = actions.select_vertical,
      },
    },
  },
  pickers = {
    find_files = {
      find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/**', '--glob', '!**/node_modules/**' }
    },
    buffers = {
      ignore_current_buffer = true,
      sort_lastused = true,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    }
  }
}

require('telescope').load_extension('fzf')

-- ------------------------------------------------------------------------
-- -- 🖥️   toggleterm.nvim: Easily manage multiple termina
-- ------------------------------------------------------------------------
-- local Terminal  = require('toggleterm.terminal').Terminal
-- local lazygit = Terminal:new({
--   cmd = "lazygit",
--   dir = "git_dir",
--   direction = "float",
--   float_opts = {
--     border = "double",
--   },
-- })
--
-- function _lazygit_toggle()
--   lazygit:toggle()
-- end
--
-- vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})


------------------------------------------------------------------------
-- 💬 Comment.nvim: Efficient code commenting for Neovim
------------------------------------------------------------------------
require('Comment').setup()

------------------------------------------------------------------------
--- 📦 nvim-autopairs: Automatically insert pairs of delimiters
------------------------------------------------------------------------
require('nvim-autopairs').setup()

------------------------------------------------------------------------
--- 📦 nvim-cmp: Autocompletion plugin for Neovim
------------------------------------------------------------------------
local cmp = require 'cmp'
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
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
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- Set configuration for specific filetype.
--[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
 require("cmp_git").setup() ]] --

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

------------------------------------------------------------------------
-- 🛠️ mason.nvim: Tool to manage LSPs, DAPs, linters, and formatters
------------------------------------------------------------------------
-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'html',
    'cssls',
    'lua_ls'
  },
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
              globals = { 'vim' }
            }
          }
        }
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
    end
  }
})

------------------------------------------------------------------------
--- 🚨 Trouble.nvim: A pretty list for showing diagnostics
------------------------------------------------------------------------
require("trouble").setup()
-- local actions = require("telescope.actions")
-- local open_with_trouble = require("trouble.sources.telescope").open
--
-- -- Use this to add more results without clearing the trouble list
-- local add_to_trouble = require("trouble.sources.telescope").add
--
-- telescope.setup({
--   defaults = {
--     mappings = {
--       i = { ["<c-t>"] = open_with_trouble },
--       n = { ["<c-t>"] = open_with_trouble },
--     },
--   },
-- })
--

------------------------------------------------------------------------
--- 🛞 fidget.nvim: Standalone UI for LSP progress notifications
------------------------------------------------------------------------
require("fidget").setup({})

------------------------------------------------------------------------
--- 🌀 lspsaga.nvim: A light-weight LSP UI with handy features
------------------------------------------------------------------------
require('lspsaga').setup({})
local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', 'gd', '<cmd>Lspsaga goto_definition <cr>', bufopts)
vim.keymap.set('n', 'gr', '<cmd>Lspsaga finder<cr>', bufopts)
vim.keymap.set('n', 'gi', '<cmd>Lspsaga finder imp<cr>', bufopts)
vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<cr>', bufopts)
vim.keymap.set('n', 'rn', '<cmd>Lspsaga rename<cr>', bufopts)
vim.keymap.set('n', '<leader>ac', '<cmd>Lspsaga code_action<cr>', bufopts)
vim.keymap.set('n', '<leader>fm', vim.lsp.buf.format, bufopts)

------------------------------------------------------------------------
--- 🌲 nvim-tree.lua: A file explorer tree for neovim
------------------------------------------------------------------------
require('nvim-tree').setup({})

------------------------------------------------------------------------
--- 🧹 nvim-eslint: A Neovim plugin for effortless ESLint integration
------------------------------------------------------------------------
require('nvim-eslint').setup({})

------------------------------------------------------------------------
--- 📑 bufferline.nvim: A snazzy buffer line for Neovim
------------------------------------------------------------------------
require("bufferline").setup({
  options = {
    mode = "tabs", }
})

------------------------------------------------------------------------
--- 🎨 nvim-colorizer.lua: A high-performance color highlighter for Neovim
------------------------------------------------------------------------
require 'colorizer'.setup()

------------------------------------------------------------------------
--- 📊 lualine.nvim: A blazing fast and easy-to-configure statusline
------------------------------------------------------------------------
local github_colors = {
  black = "#1b1f23",
  white = "#fff",
  gray = { "#fafbfc", "#f6f8fa", "#e1e4e8", "#d1d5da", "#959da5", "#6a737d", "#586069", "#444d56", "#2f363d", "#24292e" },
  blue = { "#f1f8ff", "#dbedff", "#c8e1ff", "#79b8ff", "#2188ff", "#0366d6", "#005cc5", "#044289", "#032f62", "#05264c" },
  green = { "#f0fff4", "#dcffe4", "#bef5cb", "#85e89d", "#34d058", "#28a745", "#22863a", "#176f2c", "#165c26", "#144620" },
  yellow = { "#fffdef", "#fffbdd", "#fff5b1", "#ffea7f", "#ffdf5d", "#ffd33d", "#f9c513", "#dbab09", "#b08800", "#735c0f" },
  orange = { "#fff8f2", "#ffebda", "#ffd1ac", "#ffab70", "#fb8532", "#f66a0a", "#e36209", "#d15704", "#c24e00", "#a04100" },
  red = { "#ffeef0", "#ffdce0", "#fdaeb7", "#f97583", "#ea4a5a", "#d73a49", "#cb2431", "#b31d28", "#9e1c23", "#86181d" },
  purple = { "#f5f0ff", "#e6dcfd", "#d1bcf9", "#b392f0", "#8a63d2", "#6f42c1", "#5a32a3", "#4c2889", "#3a1d6e", "#29134e" },
  pink = { "#ffeef8", "#fedbf0", "#f9b3dd", "#f692ce", "#ec6cb9", "#ea4aaa", "#d03592", "#b93a86", "#99306f", "#6d224f" }
}

local bubbles_theme = {
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

require('lualine').setup {
  options = {
    theme = bubbles_theme,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_c = {
      { 'filename',
        path = 1
      }
    }
  }
}

------------------------------------------------------------------------
--- 🌞 github-light.nvim: made with lush.nvim 
------------------------------------------------------------------------
vim.cmd('colorscheme github_light')

------------------------------------------------------------------------
--- ⚙️ local.lua: User-specific configurations for fine-tuning Neovim
------------------------------------------------------------------------
local local_config_path = vim.fn.stdpath("config") .. "/lua/local.lua"
if file_exists(local_config_path) then
  require("local")
end
