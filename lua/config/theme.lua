-- Colorscheme selection with persistence across restarts.
-- Default is iceberg; the last theme picked via M.pick() is saved and restored.

local M = {}

M.default = "iceberg"
local state_file = vim.fn.stdpath("state") .. "/colorscheme"

-- Apply the saved colorscheme (or the default). Called once at startup.
function M.load()
  local name = M.default
  local f = io.open(state_file, "r")
  if f then
    local saved = vim.trim(f:read("*a") or "")
    f:close()
    if saved ~= "" then
      name = saved
    end
  end
  if not pcall(vim.cmd.colorscheme, name) then
    pcall(vim.cmd.colorscheme, M.default)
  end
end

-- Persist a colorscheme name so it is restored next launch.
local function save(name)
  local f = io.open(state_file, "w")
  if f then
    f:write(name)
    f:close()
  end
end

-- Live-preview picker (fzf-lua); applies and persists the chosen colorscheme.
function M.pick()
  require("fzf-lua").colorschemes({
    prompt = "Colorscheme❯ ",
    winopts = { height = 0.40, width = 0.30 },
    actions = {
      ["default"] = function(selected)
        local name = selected and selected[1]
        if name and name ~= "" then
          vim.cmd.colorscheme(name)
          save(name)
        end
      end,
    },
  })
end

return M
