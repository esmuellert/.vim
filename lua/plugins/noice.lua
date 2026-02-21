-- Noice: modern UI for messages, cmdline, and notifications

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  --- 🔔 noice.nvim: Replaces the UI for messages, cmdline & popupmenu
  ------------------------------------------------------------------------
  {
    'folke/noice.nvim',
    enabled = enabled.noice,
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('noice').setup({
        cmdline = {
          enabled = true,
        },
        messages = {
          enabled = true,
          view = 'notify',
          view_error = 'notify',
          view_warn = 'notify',
        },
        popupmenu = {
          enabled = true,
          backend = 'nui',
        },
        notify = {
          enabled = true,
          view = 'notify',
        },
        lsp = {
          progress = {
            enabled = true,
          },
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
          hover = { enabled = true },
          signature = { enabled = true },
        },
        presets = {
          bottom_search = true,
          command_palette = true, -- cmdline and popupmenu together
          long_message_to_split = true,
          lsp_doc_border = true,
        },
        routes = {
          -- Skip "written" messages (e.g. "2L, 30B written")
          {
            filter = {
              event = 'msg_show',
              kind = '',
              find = 'written',
            },
            opts = { skip = true },
          },
          -- Skip search count messages (e.g. "[1/5]")
          {
            filter = {
              event = 'msg_show',
              kind = 'search_count',
            },
            opts = { skip = true },
          },
          -- Skip "search hit BOTTOM" / "search hit TOP" messages
          {
            filter = {
              event = 'msg_show',
              find = 'search hit',
            },
            opts = { skip = true },
          },
          -- Skip "No information available" from hover
          {
            filter = {
              event = 'notify',
              find = 'No information available',
            },
            opts = { skip = true },
          },
        },
      })
    end,
  },
}
