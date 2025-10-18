-- UI plugins: statusline, bufferline, indent guides

return {
  ------------------------------------------------------------------------
  --- 📊 lualine.nvim: Blazing fast statusline
  ------------------------------------------------------------------------
  {
    'nvim-lualine/lualine.nvim',
    event = 'BufRead',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local theme_config = require("config.theme")

      local function xcodebuild_device()
        if vim.g.xcodebuild_platform == "macOS" then
          return " macOS"
        end

        local deviceIcon = ""
        if vim.g.xcodebuild_platform and vim.g.xcodebuild_platform:match("watch") then
          deviceIcon = "􀟤"
        elseif vim.g.xcodebuild_platform and vim.g.xcodebuild_platform:match("tv") then
          deviceIcon = "􀡴 "
        elseif vim.g.xcodebuild_platform and vim.g.xcodebuild_platform:match("vision") then
          deviceIcon = "􁎖 "
        end

        if vim.g.xcodebuild_os then
          return deviceIcon .. " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
        end

        if vim.g.xcodebuild_device_name then
          return deviceIcon .. " " .. vim.g.xcodebuild_device_name
        end

        return ""
      end

      require('lualine').setup({
        options = {
          theme = theme_config.get_lualine_theme(),
          component_separators = '',
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
          lualine_c = {
            {
              'filename',
              path = 1
            }
          },
          lualine_z = {
            { xcodebuild_device },
            { 'location', separator = { right = '' }, left_padding = 2 },
          },
        }
      })
    end,
  },

  ------------------------------------------------------------------------
  --- 📑 bufferline.nvim: Snazzy buffer line
  ------------------------------------------------------------------------
  {
    'akinsho/bufferline.nvim',
    event = 'BufRead',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local theme_config = require("config.theme")

      require("bufferline").setup({
        options = {
          mode = "tabs",
          indicator = {
            style = 'underline'
          }
        },
        highlights = theme_config.get_bufferline_highlights()
      })
    end,
  },

  ------------------------------------------------------------------------
  -- 📏 indent-blankline.nvim: Visual indentation guides
  ------------------------------------------------------------------------
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufRead',
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = { "│" },
        },
      })
    end,
  },
}
