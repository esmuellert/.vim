-- Shared LSP helpers to avoid duplication across plugin configs

local M = {}

--- Build LSP capabilities with blink.cmp support
function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end
  return capabilities
end

--- Default on_attach: enable inlay hints if supported
function M.default_on_attach(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

return M
