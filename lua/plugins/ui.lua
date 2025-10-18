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
      local github_colors = _G.github_colors or {}

      local github_light_theme = {
        normal = {
          a = { fg = github_colors.gray and github_colors.gray[1] or "#fafbfc", bg = github_colors.purple and github_colors.purple[3] or "#d1bcf9" },
          b = { fg = github_colors.gray and github_colors.gray[6] or "#6a737d", bg = github_colors.gray and github_colors.gray[3] or "#e1e4e8" },
          c = { fg = github_colors.gray and github_colors.gray[6] or "#6a737d", bg = github_colors.gray and github_colors.gray[2] or "#f6f8fa" },
        },

        insert = { a = { fg = github_colors.gray and github_colors.gray[1] or "#fafbfc", bg = github_colors.blue and github_colors.blue[4] or "#79b8ff" } },
        visual = { a = { fg = github_colors.gray and github_colors.gray[1] or "#fafbfc", bg = github_colors.green and github_colors.green[5] or "#34d058" } },
        replace = { a = { fg = github_colors.gray and github_colors.gray[1] or "#fafbfc", bg = github_colors.pink and github_colors.pink[4] or "#f692ce" } },

        inactive = {
          a = { fg = github_colors.gray and github_colors.gray[6] or "#6a737d", bg = github_colors.gray and github_colors.gray[3] or "#e1e4e8" },
          b = { fg = github_colors.gray and github_colors.gray[6] or "#6a737d", bg = github_colors.gray and github_colors.gray[3] or "#e1e4e8" },
          c = { fg = github_colors.gray and github_colors.gray[6] or "#6a737d", bg = github_colors.gray and github_colors.gray[1] or "#fafbfc" },
        },
      }

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
          theme = github_light_theme,
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
      local github_colors = _G.github_colors or {}

      require("bufferline").setup({
        options = {
          mode = "tabs",
          indicator = {
            style = 'underline'
          }
        },
        highlights = {
          fill = {
            fg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
            bg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
          },
          background = {
            fg = github_colors.gray and github_colors.gray[6] or "#6a737d",
            bg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
          },
          buffer_selected = {
            fg = github_colors.gray and github_colors.gray[9] or "#2f363d",
            bg = github_colors.white or "#ffffff",
          },
          tab_close = {
            fg = github_colors.gray and github_colors.gray[6] or "#6a737d",
            bg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
          },
          close_button = {
            fg = github_colors.gray and github_colors.gray[6] or "#6a737d",
            bg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
          },
          separator = {
            fg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
            bg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
          },
          modified = {
            fg = github_colors.gray and github_colors.gray[9] or "#2f363d",
            bg = github_colors.gray and github_colors.gray[2] or "#f6f8fa",
          },
        }
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
