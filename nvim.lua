------------------------------------------------------------------------
-- 🌲 treesitter configuration 🌲
------------------------------------------------------------------------
require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline", "javascript", "typescript", "c_sharp", "powershell", "tsx", "html" },

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
-- 🖥️   toggleterm.nvim: Easily manage multiple terminal windows in Neovim
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
