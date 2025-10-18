-- Colorscheme configuration
-- Custom lush theme and related color settings

-- GitHub color palette (exported for use in other configs)
-- These colors are used in lualine and bufferline
_G.github_colors = {
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
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          telescope = {
            enabled = true,
          },
          mason = true,
          which_key = true,
        },
      })
      vim.cmd('colorscheme catppuccin')
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
