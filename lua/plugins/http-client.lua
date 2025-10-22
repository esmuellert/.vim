-- HTTP Client plugin configuration

local enabled = require('config.plugins-enabled')

return {
  ------------------------------------------------------------------------
  -- 🐼 kulala.nvim: REST Client for Neovim
  ------------------------------------------------------------------------
  {
    "mistweaverco/kulala.nvim",
    enabled = enabled.kulala,
    ft = { "http", "rest" },
    keys = {
      { "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request" },
      { "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body" },
      { "<leader>Rp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request" },
      { "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request" },
      { "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request" },
      { "<leader>Re", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Set environment" },
      { "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL" },
      { "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from cURL" },
      { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" },
    },
    opts = {
      default_view = "body",
      default_env = "dev",
      debug = false,
      contenttypes = {
        ["application/json"] = {
          ft = "json",
          formatter = { "jq", "." },
          pathresolver = { "jq", "-r" },
        },
        ["application/xml"] = {
          ft = "xml",
          formatter = { "xmllint", "--format", "-" },
          pathresolver = {},
        },
        ["text/html"] = {
          ft = "html",
          formatter = { "xmllint", "--format", "--html", "-" },
          pathresolver = {},
        },
      },
    },
  },
}
