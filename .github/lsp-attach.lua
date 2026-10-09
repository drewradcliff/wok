-- Exits nonzero unless a language server attaches to the current buffer.
-- The first open downloads the server, so this waits for that too. It waits
-- with events rather than vim.wait: this runs before VimEnter, and blocking
-- here would keep vim.lsp.enable from attaching servers to open buffers.
local buf = vim.api.nvim_get_current_buf()

local function check()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  if #clients == 0 then
    return false
  end
  for _, client in ipairs(clients) do
    io.stdout:write(("%s attached\n"):format(client.name))
  end
  vim.cmd.qall({ bang = true })
  return true
end

if not check() then
  vim.api.nvim_create_autocmd("LspAttach", { buffer = buf, callback = check })
  vim.defer_fn(function()
    io.stderr:write(("No language server attached to %s\n"):format(vim.api.nvim_buf_get_name(buf)))
    io.stderr:write(vim.fn.execute("messages"), "\n")
    vim.cmd.cquit()
  end, 180000)
end
