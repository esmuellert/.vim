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
    config = function(_, opts)
      require("kulala").setup(opts)
      
      -- Set up keymaps (only loaded when plugin loads)
      vim.keymap.set("n", "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", { desc = "Send the request" })
      vim.keymap.set("n", "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", { desc = "Toggle headers/body" })
      vim.keymap.set("n", "<leader>Rp", "<cmd>lua require('kulala').jump_prev()<cr>", { desc = "Jump to previous request" })
      vim.keymap.set("n", "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", { desc = "Jump to next request" })
      vim.keymap.set("n", "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", { desc = "Inspect current request" })
      vim.keymap.set("n", "<leader>Re", "<cmd>lua require('kulala').set_selected_env()<cr>", { desc = "Set environment" })
      vim.keymap.set("n", "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", { desc = "Copy as cURL" })
      vim.keymap.set("n", "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", { desc = "Paste from cURL" })
      vim.keymap.set("n", "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", { desc = "Open scratchpad" })
    end,
  },
}
