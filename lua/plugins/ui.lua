-- UI plugins: statusline, bufferline, indent guides

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  --- 📊 lualine.nvim: Blazing fast statusline
  ------------------------------------------------------------------------
  {
    enabled = enabled.lualine,
    'nvim-lualine/lualine.nvim',
    event = 'BufRead',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local theme_config = require('config.theme')

      local function xcodebuild_device()
        if vim.g.xcodebuild_platform == 'macOS' then
          return ' macOS'
        end

        local deviceIcon = ''
        if vim.g.xcodebuild_platform and vim.g.xcodebuild_platform:match('watch') then
          deviceIcon = '􀟤'
        elseif vim.g.xcodebuild_platform and vim.g.xcodebuild_platform:match('tv') then
          deviceIcon = '􀡴 '
        elseif vim.g.xcodebuild_platform and vim.g.xcodebuild_platform:match('vision') then
          deviceIcon = '􁎖 '
        end

        if vim.g.xcodebuild_os then
          return deviceIcon .. ' ' .. vim.g.xcodebuild_device_name .. ' (' .. vim.g.xcodebuild_os .. ')'
        end

        if vim.g.xcodebuild_device_name then
          return deviceIcon .. ' ' .. vim.g.xcodebuild_device_name
        end

        return ''
      end

      require('lualine').setup({
        options = {
          theme = theme_config.get_lualine_theme(),
          component_separators = '',
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
          lualine_c = {
            {
              'filename',
              path = 1,
            },
          },
          lualine_z = {
            { xcodebuild_device },
            { 'location', separator = { right = '' }, left_padding = 2 },
          },
        },
      })
    end,
  },

  ------------------------------------------------------------------------
  --- 📑 bufferline.nvim: Snazzy buffer line
  ------------------------------------------------------------------------
  {
    enabled = enabled.bufferline,
    'akinsho/bufferline.nvim',
    event = 'BufRead',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local theme_config = require('config.theme')

      require('bufferline').setup({
        options = {
          mode = 'tabs',
          indicator = {
            style = 'underline',
          },
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'File Explorer',
              text_align = 'center',
              separator = true,
            },
          },
        },
        highlights = theme_config.get_bufferline_highlights(),
      })
    end,
  },

  ------------------------------------------------------------------------
  -- 📏 indent-blankline.nvim: Visual indentation guides
  ------------------------------------------------------------------------
  {
    enabled = enabled.indent_blankline,
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufRead',
    main = 'ibl',
    config = function()
      require('ibl').setup({
        indent = {
          char = '│',
          tab_char = { '│' },
        },
      })
    end,
  },

  ------------------------------------------------------------------------
  -- 📝 render-markdown.nvim: Render markdown in Neovim
  ------------------------------------------------------------------------
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = enabled.render_markdown,
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {
      -- Ignore codediff virtual buffers to avoid treesitter yield errors on Neovim 0.12
      ignore = function(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        return name:match('^vscodediff://') ~= nil
      end,
    },
  },
}
