-- codediff.nvim: VSCode-style inline diff explorer (local development plugin)

return {
  {
    "esmuellert/codediff.nvim",
    dev = true,
    pin = false,
    cmd = { "CodeDiff" },
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>df", "<cmd>CodeDiff<cr>", desc = "Code Diff Explorer" },
      { "<leader>dh", "<cmd>CodeDiff history<CR>", desc = "Code Diff History" },
      {
        "<leader>dm",
        function()
          local main = vim.fn.system("git rev-parse --verify --quiet main"):find("%S") and "main" or "master"
          vim.cmd("CodeDiff " .. main .. "...")
        end,
        desc = "Code Diff vs main/master",
      },
    },
    opts = {
      diff = {
        compute_moves = true,
        layout = "side-by-side",
      },
      explorer = {
        view_mode = "tree",
      },
      keymaps = {
        view = {
          focus_explorer = "<leader>fe",
        },
      },
    },
    config = function(_, opts)
      require("codediff").setup(opts)

      -- Soften NonText in codediff-history buffers
      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
        callback = function()
          if vim.bo.filetype == "codediff-history" then
            local whl = vim.wo.winhighlight
            if not whl:find("NonText") then
              vim.wo.winhighlight = (whl ~= "" and whl .. "," or "") .. "NonText:Comment"
            end
          end
        end,
      })
    end,
  },
}
