------------------------------------------------------------------------
--- Custom utility functions
------------------------------------------------------------------------
--- Check if the current OS is Windows
function is_windows()
  return vim.loop.os_uname().sysname == 'Windows'
end

------------------------------------------------------------------------
-- ⌨️ Custom Shortcuts
------------------------------------------------------------------------
--- Prettier format current buffer
vim.api.nvim_set_keymap('n', '<A-S-F>', ':w!<CR> :!pnpm exec prettier --write %<CR> :edit!<CR>', { noremap = true, silent = true })

------------------------------------------------------------------------
-- 🌲 treesitter configuration 🌲
------------------------------------------------------------------------
require'nvim-treesitter.configs'.setup {
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
    -- disable = { "c", "rust" },
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
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
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
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
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
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
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
require("diffview").setup ({
  enhanced_diff_hl = true
})

------------------------------------------------------------------------
-- 📏 indent-blankline.nvim: Visual indentation guides for Neovim
------------------------------------------------------------------------
require("ibl").setup {
  indent = {
    char = "│"
  },
}


------------------------------------------------------------------------
-- 🎨 github-nvim-theme: GitHub-inspired colors for Neovim
------------------------------------------------------------------------
require("github-theme").setup()


------------------------------------------------------------------------
-- 🔭 telescope.nvim: Fuzzy finder and picker for Neovim
------------------------------------------------------------------------
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>p', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>hp', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>pd', [[:lua require('telescope.builtin').find_files({ cwd = vim.fn.input("Enter directory: ", "", "dir") })<CR>]], { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fd', [[:lua require('telescope.builtin').live_grep({ cwd = vim.fn.input("Enter directory: ", "", "dir") })<CR>]], { noremap = true, silent = true })

-- Add devicons to telescope
local devicons = require"nvim-web-devicons"
-- Close telescope with <esc>
local actions = require("telescope.actions")
require("telescope").setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  },
  pickers = {
    find_files = {
      find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/**', '--glob', '!**/node_modules/**' }
    }
  }
}

------------------------------------------------------------------------
-- 🖥️   toggleterm.nvim: Easily manage multiple termina
------------------------------------------------------------------------
local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "double",
  },
})

function _lazygit_toggle()
  lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})


------------------------------------------------------------------------
-- 💬 Comment.nvim: Efficient code commenting for Neovim
------------------------------------------------------------------------
require('Comment').setup()

------------------------------------------------------------------------
--- 📦 nvim-autopairs: Automatically insert pairs of delimiters
------------------------------------------------------------------------
require('nvim-autopairs').setup()

------------------------------------------------------------------------
-- 🛠️ mason.nvim: Tool to manage LSPs, DAPs, linters, and formatters
------------------------------------------------------------------------
-- Key mappings on LSP attach
local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd',require('telescope.builtin').lsp_definitions, bufopts)
  vim.keymap.set('n', 'gr',require('telescope.builtin').lsp_references, bufopts)
  vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, bufopts)
end
--- nvim.cmp
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
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
    { name = 'vsnip' }, -- For vsnip users.
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
 require("cmp_git").setup() ]]-- 

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

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require('lspconfig')

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'eslint',
    'html',
    'cssls',
    'omnisharp'
  },
  handlers = {
    function(server)
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = on_attach
      })
    end,
    ['eslint'] = function()
      lspconfig['eslint'].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          workingDirectories = {
            mode = 'auto'
          }
        }
      })
    end,
    ['omnisharp'] = function()
      lspconfig['omnisharp'].setup{
        capabilities = capabilities,

        cmd = { 'dotnet', 'C:\\Users\\yanuoma\\AppData\\Local\\nvim-data\\mason\\packages\\omnisharp\\libexec\\omnisharp.dll' },
        on_attach = function(_, bufnr)
          vim.keymap.set('n', 'gd', "<cmd>lua require('omnisharp_extended').telescope_lsp_definitions()<cr>", { buffer = bufnr, desc = 'Goto [d]efinition' })

          vim.keymap.set('n', 'gr', "<cmd>lua require('omnisharp_extended').telescope_lsp_references()<cr>", { buffer = bufnr, desc = 'Goto [r]eferences' })

          vim.keymap.set(
            'n',
            'gi',
            "<cmd>lua require('omnisharp_extended').telescope_lsp_implementation()<cr>",
            { buffer = bufnr, desc = 'Goto [I]mplementation' }
          )

          vim.keymap.set(
            'n',
            'gD',
            "<cmd>lua require('omnisharp_extended').telescope_type_definitions()<cr>",
            { buffer = bufnr, desc = 'Goto Type [D]efinition' }
          )
        end,
        root_dir = function(fname)
          local lspconfig = require 'lspconfig'
          local primary = lspconfig.util.root_pattern '*.sln'(fname)
          local fallback = lspconfig.util.root_pattern '*.csproj'(fname)
          return primary or fallback
        end,
        enable_roslyn_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
        settings = {
          FormattingOptions = {
            -- Enables support for reading code style, naming convention and analyzer
            -- settings from .editorconfig.
            EnableEditorConfigSupport = true,
            -- Specifies whether 'using' directives should be grouped and sorted during
            -- document formatting.
            OrganizeImports = true,
          },
          MsBuild = {
            -- If true, MSBuild project system will only load projects for files that
            -- were opened in the editor. This setting is useful for big C# codebases
            -- and allows for faster initialization of code navigation features only
            -- for projects that are relevant to code that is being edited. With this
            -- setting enabled OmniSharp may load fewer projects and may thus display
            -- incomplete reference lists for symbols.
            LoadProjectsOnDemand = nil,
          },
          RoslynExtensionsOptions = {
            -- Enables support for roslyn analyzers, code fixes and rulesets.
            EnableAnalyzersSupport = true,
            -- Enables support for showing unimported types and unimported extension
            -- methods in completion lists. When committed, the appropriate using
            -- directive will be added at the top of the current file. This option can
            -- have a negative impact on initial completion responsiveness,
            -- particularly for the first few completion sessions after opening a
            -- solution.
            EnableImportCompletion = true,
            -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
            -- true
            AnalyzeOpenDocumentsOnly = nil,
            -- Decompilation support
            EnableDecompilationSupport = true,
            -- Inlay Hints
            -- InlayHintsOptions = {
            --   EnableForParameters = true,
            --   ForLiteralParameters = true,
            --   ForIndexerParameters = true,
            --   ForObjectCreationParameters = true,
            --   ForOtherParameters = true,
            --   SuppressForParametersThatDifferOnlyBySuffix = false,
            --   SuppressForParametersThatMatchMethodIntent = false,
            --   SuppressForParametersThatMatchArgumentName = false,
            --   EnableForTypes = true,
            --   ForImplicitVariableTypes = true,
            --   ForLambdaParameterTypes = true,
            --   ForImplicitObjectCreation = true,
            -- },
          },
          Sdk = {
            -- Specifies whether to include preview versions of the .NET SDK when
            -- determining which version to use for project loading.
            IncludePrereleases = true,
          },
        },
      }
    end
  }
})

------------------------------------------------------------------------
--- 🚨 Trouble.nvim: A pretty list for showing diagnostics
------------------------------------------------------------------------
require("trouble").setup()
local actions = require("telescope.actions")
local open_with_trouble = require("trouble.sources.telescope").open

-- Use this to add more results without clearing the trouble list
local add_to_trouble = require("trouble.sources.telescope").add

local telescope = require("telescope")

telescope.setup({
  defaults = {
    mappings = {
      i = { ["<c-t>"] = open_with_trouble },
      n = { ["<c-t>"] = open_with_trouble },
    },
  },
})
