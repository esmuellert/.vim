-- Completion configuration

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  --- 📦 blink.cmp: Fast completion engine powered by Rust
  ------------------------------------------------------------------------
  {
    'saghen/blink.cmp',
    enabled = enabled.blink_cmp,
    version = '1.*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    opts = {
      keymap = {
        preset = 'default',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        list = {
          selection = { preselect = true, auto_insert = false },
        },
        menu = {
          draw = {
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
          },
        },
      },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'buffer' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      cmdline = {
        sources = { 'cmdline', 'path' },
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      fuzzy = {
        implementation = 'prefer_rust_with_warning',
      },
    },
  },
}
