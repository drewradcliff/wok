-- Exits nonzero unless a language server attaches to the current buffer.
-- The first open downloads the server, so this waits for that too.
local buf = vim.api.nvim_get_current_buf()
local attached = vim.wait(180000, function()
  return #vim.lsp.get_clients({ bufnr = buf }) > 0
end, 500)

if not attached then
  io.stderr:write(("No language server attached to %s\n"):format(vim.api.nvim_buf_get_name(buf)))
  io.stderr:write(vim.fn.execute("messages"), "\n")
  vim.cmd.cquit()
end

for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
  io.stdout:write(("%s attached\n"):format(client.name))
end
vim.cmd.qall({ bang = true })
