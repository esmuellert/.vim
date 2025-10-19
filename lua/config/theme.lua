-- Centralized theme configuration
-- This module provides theme settings for lualine, bufferline, etc.

local M = {}

-- GitHub color palette (for github_light theme)
M.github_colors = {
  black = "#24292e",
  white = "#ffffff",
  gray = { "#fafbfc", "#f6f8fa", "#e1e4e8", "#d1d5da", "#959da5", "#6a737d", "#586069", "#444d56", "#2f363d", "#24292e" },
  blue = { "#f1f8ff", "#dbedff", "#c8e1ff", "#79b8ff", "#2188ff", "#0366d6", "#005cc5", "#044289", "#032f62", "#05264c" },
  green = { "#f0fff4", "#dcffe4", "#bef5cb", "#85e89d", "#34d058", "#28a745", "#22863a", "#176f2c", "#165c26", "#144620" },
  yellow = { "#fffdef", "#fffbdd", "#fff5b1", "#ffea7f", "#ffdf5d", "#ffd33d", "#f9c513", "#dbab09", "#b08800", "#735c0f" },
  orange = { "#fff8f2", "#ffebda", "#ffd1ac", "#ffab70", "#fb8532", "#f66a0a", "#e36209", "#d15704", "#c24e00", "#a04100" },
  red = { "#ffeef0", "#ffdce0", "#fdaeb7", "#f97583", "#ea4a5a", "#d73a49", "#cb2431", "#b31d28", "#9e1c23", "#86181d" },
  purple = { "#f5f0ff", "#e6dcfd", "#d1bcf9", "#b392f0", "#8a63d2", "#6f42c1", "#5a32a3", "#4c2889", "#3a1d6e", "#29134e" },
  pink = { "#ffeef8", "#fedbf0", "#f9b3dd", "#f692ce", "#ec6cb9", "#ea4aaa", "#d03592", "#b93a86", "#99306f", "#6d224f" }
}

-- GitHub Light theme for lualine
M.github_light_lualine = {
  normal = {
    a = { fg = M.github_colors.gray[1], bg = M.github_colors.purple[3] },
    b = { fg = M.github_colors.gray[6], bg = M.github_colors.gray[3] },
    c = { fg = M.github_colors.gray[6], bg = M.github_colors.gray[2] },
  },
  insert = { a = { fg = M.github_colors.gray[1], bg = M.github_colors.blue[4] } },
  visual = { a = { fg = M.github_colors.gray[1], bg = M.github_colors.green[5] } },
  replace = { a = { fg = M.github_colors.gray[1], bg = M.github_colors.pink[4] } },
  inactive = {
    a = { fg = M.github_colors.gray[6], bg = M.github_colors.gray[3] },
    b = { fg = M.github_colors.gray[6], bg = M.github_colors.gray[3] },
    c = { fg = M.github_colors.gray[6], bg = M.github_colors.gray[1] },
  },
}

-- GitHub Light theme for bufferline
M.github_light_bufferline = {
  fill = {
    fg = M.github_colors.gray[2],
    bg = M.github_colors.gray[2],
  },
  background = {
    fg = M.github_colors.gray[6],
    bg = M.github_colors.gray[2],
  },
  buffer_selected = {
    fg = M.github_colors.gray[9],
    bg = M.github_colors.white,
  },
  tab_close = {
    fg = M.github_colors.gray[6],
    bg = M.github_colors.gray[2],
  },
  close_button = {
    fg = M.github_colors.gray[6],
    bg = M.github_colors.gray[2],
  },
  separator = {
    fg = M.github_colors.gray[2],
    bg = M.github_colors.gray[2],
  },
  modified = {
    fg = M.github_colors.gray[9],
    bg = M.github_colors.gray[2],
  },
}

-- Get lualine theme based on current colorscheme
function M.get_lualine_theme()
  local colorscheme = vim.g.colors_name or ""

  if colorscheme:match("tokyonight") then
    return "tokyonight"
  elseif colorscheme:match("catppuccin") then
    return "catppuccin"
  elseif colorscheme:match("github") then
    return M.github_light_lualine
  else
    return "auto"
  end
end

-- Get bufferline highlights based on current colorscheme
function M.get_bufferline_highlights()
  local colorscheme = vim.g.colors_name or ""

  if colorscheme:match("tokyonight") then
    -- Tokyo Night automatically applies bufferline highlights
    return {}
  elseif colorscheme:match("catppuccin") then
    -- Catppuccin automatically applies bufferline highlights
    return {}
  elseif colorscheme:match("github") then
    return M.github_light_bufferline
  else
    -- Return empty table for unknown themes
    return {}
  end
end

return M
