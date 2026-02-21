-- Autocommands

-- Note: File reload handling is now in file_reload.lua
-- Note: Large/minified file handling is now in snacks.nvim (bigfile)

------------------------------------------------------------------------
--- Diagnostic line highlighting setup
------------------------------------------------------------------------
-- Setup diagnostic line highlights with only background color from theme
local function setup_diagnostic_line_highlights()
  -- Get colors from DiagnosticVirtualText highlights
  local error_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextError' })
  local warn_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextWarn' })
  local hint_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextHint' })
  local info_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextInfo' })

  -- Set line highlights with only background color (preserving text color)
  vim.api.nvim_set_hl(0, 'DiagnosticLineError', { bg = error_hl.bg })
  vim.api.nvim_set_hl(0, 'DiagnosticLineWarn', { bg = warn_hl.bg })
  vim.api.nvim_set_hl(0, 'DiagnosticLineHint', { bg = hint_hl.bg })
  vim.api.nvim_set_hl(0, 'DiagnosticLineInfo', { bg = info_hl.bg })

  -- Set underline highlights with diagnostic color
  -- Use sp for undercurl color and nocombine to prevent fg from being combined
  -- Note: colored undercurls require terminal support (termguicolors + undercurl color support)
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', {
    undercurl = true,
    sp = error_hl.fg,
    nocombine = true,
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', {
    undercurl = true,
    sp = warn_hl.fg,
    nocombine = true,
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', {
    undercurl = true,
    sp = hint_hl.fg,
    nocombine = true,
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', {
    undercurl = true,
    sp = info_hl.fg,
    nocombine = true,
  })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('DiagnosticLineHL', { clear = true }),
  callback = setup_diagnostic_line_highlights,
  desc = 'Setup diagnostic line highlighting for all colorschemes',
})

-- Apply immediately for current colorscheme with delay
vim.defer_fn(setup_diagnostic_line_highlights, 200)

------------------------------------------------------------------------
--- Auto-update Neovim config when on main and clean
------------------------------------------------------------------------
local function auto_update_config_repo()
  local config_path = vim.fn.stdpath('config')

  if vim.g.__config_auto_update_ran or vim.fn.isdirectory(config_path .. '/.git') == 0 then
    return
  end
  vim.g.__config_auto_update_ran = true

  local function git_cmd(args)
    local cmd = { 'git', '-C', config_path }
    vim.list_extend(cmd, args)
    local output = vim.fn.systemlist(cmd)
    local code = vim.v.shell_error
    return output, code
  end

  local function is_empty(output)
    return output == nil or #output == 0 or (#output == 1 and output[1] == '')
  end

  local branch_out, branch_code = git_cmd({ 'rev-parse', '--abbrev-ref', 'HEAD' })
  if branch_code ~= 0 then
    return
  end

  local branch = vim.trim(branch_out[1] or '')
  if branch ~= 'main' then
    return
  end

  local status_out, status_code = git_cmd({ 'status', '--porcelain' })
  if status_code ~= 0 or not is_empty(status_out) then
    return
  end

  -- Ensure the upstream reference exists before attempting to pull
  local upstream_out, upstream_code = git_cmd({ 'rev-parse', '--abbrev-ref', '@{upstream}' })
  if upstream_code ~= 0 then
    return
  end
  local upstream = vim.trim(upstream_out[1] or '')
  if upstream == '' then
    return
  end

  local function notify(lines, level)
    local filtered = {}
    for _, line in ipairs(lines or {}) do
      if line and line ~= '' then
        table.insert(filtered, line)
      end
    end
    if #filtered == 0 then
      return
    end
    vim.schedule(function()
      vim.notify(table.concat(filtered, '\n'), level, { title = 'Neovim config update' })
    end)
  end

  -- Fetch latest changes asynchronously to avoid blocking the UI
  vim.system({ 'git', '-C', config_path, 'fetch', '--quiet' }, {}, function(fetch_result)
    if fetch_result.code ~= 0 then
      return
    end

    local ahead_out, ahead_code = git_cmd({ 'rev-list', '--count', 'HEAD..' .. upstream })
    if ahead_code ~= 0 then
      return
    end

    local ahead_count = tonumber(vim.trim(ahead_out[1] or '0')) or 0
    if ahead_count == 0 then
      return
    end

    vim.schedule(function()
      vim.fn.jobstart({ 'git', '-C', config_path, 'pull', '--ff-only' }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
          notify(data, vim.log.levels.INFO)
        end,
        on_stderr = function(_, data)
          notify(data, vim.log.levels.WARN)
        end,
        on_exit = function(_, code)
          if code == 0 then
            notify({ 'Config updated from ' .. upstream }, vim.log.levels.INFO)
          else
            notify({ 'git pull failed (exit ' .. code .. ')' }, vim.log.levels.ERROR)
          end
        end,
      })
    end)
  end)
end

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('ConfigAutoUpdate', { clear = true }),
  once = true,
  callback = auto_update_config_repo,
  desc = 'Pull latest config when clean and behind upstream',
})
