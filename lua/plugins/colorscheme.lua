-- Colorscheme configuration
-- All theme-specific settings are now in lua/config/theme.lua

-- Export github colors for backward compatibility
_G.github_colors = require("config.theme").github_colors

return {
  ------------------------------------------------------------------------
  --- 🌿 lush.nvim: A Neovim plugin for building and customizing themes with ease
  ------------------------------------------------------------------------
  -- DISABLED: Custom github_light theme
  -- {
  --   'rktjmp/lush.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- Load the custom github_light theme
  --     -- The theme file is in lua/themes/github_light.lua
  --     vim.cmd('colorscheme github_light')
  --   end,
  -- },

  ------------------------------------------------------------------------
  --- 🎨 Catppuccin: Soothing pastel theme for Neovim
  ------------------------------------------------------------------------
  -- DISABLED: Trying Tokyo Night instead
  -- {
  --   'catppuccin/nvim',
  --   name = 'catppuccin',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("catppuccin").setup({
  --       flavour = "mocha", -- latte, frappe, macchiato, mocha
  --       background = {
  --         light = "latte",
  --         dark = "mocha",
  --       },
  --       transparent_background = false,
  --       show_end_of_buffer = false,
  --       term_colors = false,
  --       dim_inactive = {
  --         enabled = false,
  --         shade = "dark",
  --         percentage = 0.15,
  --       },
  --       no_italic = false,
  --       no_bold = false,
  --       no_underline = false,
  --       styles = {
  --         comments = { "italic" },
  --         conditionals = { "italic" },
  --       },
  --       integrations = {
  --         cmp = true,
  --         gitsigns = true,
  --         nvimtree = true,
  --         treesitter = true,
  --         telescope = {
  --           enabled = true,
  --         },
  --         mason = true,
  --         which_key = true,
  --         bufferline = true,
  --         diffview = true,
  --         native_lsp = {
  --           enabled = true,
  --           virtual_text = {
  --             errors = { "italic" },
  --             hints = { "italic" },
  --             warnings = { "italic" },
  --             information = { "italic" },
  --           },
  --           underlines = {
  --             errors = { "underline" },
  --             hints = { "underline" },
  --             warnings = { "underline" },
  --             information = { "underline" },
  --           },
  --         },
  --       },
  --       custom_highlights = function(colors)
  --         return {
  --           -- Additional custom highlights if needed
  --         }
  --       end,
  --     })
  --     vim.cmd('colorscheme catppuccin')
  --     
  --     -- Trigger UI refresh after theme loads
  --     vim.defer_fn(function()
  --       vim.cmd('redraw')
  --     end, 100)
  --   end,
  -- },

  ------------------------------------------------------------------------
  --- 🏙️ Tokyo Night: A clean, dark Neovim theme
  ------------------------------------------------------------------------
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- Set background to dark BEFORE loading the theme
      vim.o.background = "dark"
      
      require("tokyonight").setup({
        style = "moon", -- storm, moon, night, day
        light_style = "day",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help", "vista_kind", "terminal", "packer" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,

        --- You can override specific color groups to use other groups or a hex color
        --- function will be called with a ColorScheme table
        on_colors = function(colors) end,

        --- You can override specific highlights to use other groups or a hex color
        --- function will be called with a Highlights and ColorScheme table
        on_highlights = function(highlights, colors)
          -- Diffview file panel customizations for better visibility
          highlights.DiffviewFilePanelTitle = { fg = colors.blue, bg = colors.bg_dark, bold = true }
          highlights.DiffviewFilePanelCounter = { fg = colors.fg_dark, bg = colors.bg_dark }
          highlights.DiffviewFilePanelFileName = { fg = colors.fg, bg = "NONE" }
          highlights.DiffviewFilePanelPath = { fg = colors.fg_dark, bg = "NONE" }
          highlights.DiffviewFilePanelSelected = { fg = colors.blue, bg = colors.bg_highlight, bold = true }
          highlights.DiffviewFilePanelInsertions = { fg = colors.green, bg = "NONE" }
          highlights.DiffviewFilePanelDeletions = { fg = colors.red, bg = "NONE" }
          highlights.DiffviewFolderName = { fg = colors.blue, bg = "NONE", bold = true }
          highlights.DiffviewFolderSign = { fg = colors.blue, bg = "NONE" }
          highlights.DiffviewStatusAdded = { fg = colors.green, bg = "NONE" }
          highlights.DiffviewStatusModified = { fg = colors.blue, bg = "NONE" }
          highlights.DiffviewStatusRenamed = { fg = colors.purple, bg = "NONE" }
          highlights.DiffviewStatusDeleted = { fg = colors.red, bg = "NONE" }
          highlights.DiffviewStatusUntracked = { fg = colors.fg_dark, bg = "NONE" }
        end,

        -- Plugin integrations (all enabled for your setup)
        plugins = {
          -- Enable all the plugins you have installed
          auto = true, -- Automatically enable all available integrations
        },
      })

      vim.cmd('colorscheme tokyonight-moon')
    end,
  },

  ------------------------------------------------------------------------
  --- 🎨 nvim-colorizer.lua: A high-performance color highlighter for Neovim
  ------------------------------------------------------------------------
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },
}

--[[
To switch themes:
1. Comment out the github_light plugin above
2. Uncomment one of the themes below
3. Update the colorscheme command

Example alternative themes:
  {
    'projekt0n/github-nvim-theme',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme github_light')
    end,
  },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme tokyonight')
    end,
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme catppuccin')
    end,
  },
]]
