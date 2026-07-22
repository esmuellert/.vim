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

-- Extract a short SHA from an fzf-lua git commit entry.
local function commit_sha(selected)
  if not selected or not selected[1] then
    return nil
  end
  return require("fzf-lua.utils").strip_ansi_coloring(selected[1]):match("^%s*(%x%x%x%x+)")
end

-- Pick a commit with fzf-lua, then diff the working tree against it.
local function codediff_commit()
  require("fzf-lua").git_commits({
    prompt = "CodeDiff commit❯ ",
    actions = {
      ["default"] = function(selected)
        local sha = commit_sha(selected)
        if sha then
          vim.cmd("CodeDiff " .. sha)
        end
      end,
    },
  })
end

-- Pick a commit, then show that commit's own changes (parent vs commit).
local function codediff_show_commit()
  require("fzf-lua").git_commits({
    prompt = "CodeDiff show commit❯ ",
    actions = {
      ["default"] = function(selected)
        local sha = commit_sha(selected)
        if sha then
          vim.cmd("CodeDiff " .. sha .. "~ " .. sha)
        end
      end,
    },
  })
end

-- Pick a commit that touched the current file, then show that commit's changes.
local function codediff_file_commit()
  require("fzf-lua").git_bcommits({
    prompt = "CodeDiff file commit❯ ",
    actions = {
      ["default"] = function(selected)
        local sha = commit_sha(selected)
        if sha then
          vim.cmd("CodeDiff " .. sha .. "~ " .. sha)
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

-- Prompt for a number N and diff the working tree against HEAD~N.
local function codediff_head_n()
  vim.ui.input({ prompt = "CodeDiff HEAD~" }, function(input)
    if not input or vim.trim(input) == "" then
      return
    end
    local n = tonumber(input)
    if n and n >= 0 and n == math.floor(n) then
      vim.cmd("CodeDiff HEAD~" .. n)
    else
      vim.notify("CodeDiff: invalid number '" .. input .. "'", vim.log.levels.WARN)
    end
  end)
end

-- Keymap list; <leader>d1..d9 are generated below (not hardcoded).
local keys = {
  -- Working tree (staged + unstaged). <leader>d aliases <leader>df.
  { "<leader>d", "<cmd>CodeDiff<cr>", desc = "CodeDiff: working tree" },
  { "<leader>df", "<cmd>CodeDiff<cr>", desc = "CodeDiff: working tree" },
  { "<leader>dh", "<cmd>CodeDiff history<cr>", desc = "CodeDiff: history" },
  { "<leader>dm", codediff_main, desc = "CodeDiff: vs main/master" },
  { "<leader>dn", codediff_head_n, desc = "CodeDiff: vs HEAD~N (prompt)" },
  -- Pickers / prompt
  { "<leader>db", codediff_branch, desc = "CodeDiff: vs branch (pick)" },
  { "<leader>dc", codediff_commit, desc = "CodeDiff: vs commit (pick)" },
  { "<leader>ds", codediff_show_commit, desc = "CodeDiff: show commit changes (pick)" },
  { "<leader>dC", codediff_file_commit, desc = "CodeDiff: current file commit (pick)" },
  { "<leader>dr", codediff_ref, desc = "CodeDiff: vs ref (prompt)" },
}

-- <leader>d1..d9 -> instant CodeDiff HEAD~1..9
for d = 1, 9 do
  table.insert(keys, {
    "<leader>d" .. d,
    "<cmd>CodeDiff HEAD~" .. d .. "<cr>",
    desc = "CodeDiff: vs HEAD~" .. d,
  })
end

return {
  {
    "esmuellert/codediff.nvim",
    dev = true,
    pin = false,
    cmd = { "CodeDiff" },
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = keys,
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
