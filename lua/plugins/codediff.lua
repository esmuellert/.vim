-- codediff.nvim: VSCode-style inline diff explorer (local development plugin)

-- Diff the working tree against the merge-base with main (or master).
local function codediff_main()
  local main = vim.fn.system("git rev-parse --verify --quiet main"):find("%S") and "main" or "master"
  vim.cmd("CodeDiff " .. main .. "...")
end

-- Pick a branch with fzf-lua, then merge-base diff the working tree against it.
local function codediff_branch()
  local fzf = require("fzf-lua")
  fzf.git_branches({
    prompt = "CodeDiff branch❯ ",
    actions = {
      ["default"] = function(selected)
        if not selected or not selected[1] then
          return
        end
        local entry = require("fzf-lua.utils").strip_ansi_coloring(selected[1])
        local branch = entry:match("^[%*+]*%s*[(]?([^%s)]+)")
        if branch and branch ~= "" then
          vim.cmd("CodeDiff " .. branch:gsub("^remotes/", "") .. "...")
        end
      end,
    },
  })
end

-- Pick a commit with fzf-lua, then diff the working tree against it.
local function codediff_commit()
  local fzf = require("fzf-lua")
  fzf.git_commits({
    prompt = "CodeDiff commit❯ ",
    actions = {
      ["default"] = function(selected)
        if not selected or not selected[1] then
          return
        end
        local entry = require("fzf-lua.utils").strip_ansi_coloring(selected[1])
        local sha = entry:match("^%s*(%x%x%x%x+)")
        if sha then
          vim.cmd("CodeDiff " .. sha)
        end
      end,
    },
  })
end

-- Prompt for an arbitrary revision / revspec.
local function codediff_ref()
  vim.ui.input({ prompt = "CodeDiff ref (e.g. HEAD~5, origin/main..., v1.0): " }, function(ref)
    if ref and vim.trim(ref) ~= "" then
      vim.cmd("CodeDiff " .. vim.trim(ref))
    end
  end)
end

return {
  {
    "esmuellert/codediff.nvim",
    dev = true,
    pin = false,
    cmd = { "CodeDiff" },
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      -- Working tree (staged + unstaged). <leader>d aliases <leader>df.
      { "<leader>d", "<cmd>CodeDiff<cr>", desc = "CodeDiff: working tree" },
      { "<leader>df", "<cmd>CodeDiff<cr>", desc = "CodeDiff: working tree" },
      { "<leader>dh", "<cmd>CodeDiff history<cr>", desc = "CodeDiff: history" },
      { "<leader>dm", codediff_main, desc = "CodeDiff: vs main/master" },
      -- Recent commits
      { "<leader>d1", "<cmd>CodeDiff HEAD~1<cr>", desc = "CodeDiff: vs HEAD~1" },
      { "<leader>d2", "<cmd>CodeDiff HEAD~2<cr>", desc = "CodeDiff: vs HEAD~2" },
      { "<leader>d3", "<cmd>CodeDiff HEAD~3<cr>", desc = "CodeDiff: vs HEAD~3" },
      -- Pickers / prompt
      { "<leader>db", codediff_branch, desc = "CodeDiff: vs branch (pick)" },
      { "<leader>dc", codediff_commit, desc = "CodeDiff: vs commit (pick)" },
      { "<leader>dr", codediff_ref, desc = "CodeDiff: vs ref (prompt)" },
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
