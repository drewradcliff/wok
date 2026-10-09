-- Shows the signature of the function being called while you type its
-- arguments, like VS Code: it opens on the server's trigger characters such
-- as "(" and ",", follows the active parameter as you type, and closes when
-- you leave the call or insert mode. It sits above the line, clear of the
-- completion menu.
local util = vim.lsp.util
local ns = vim.api.nvim_create_namespace("wok.signature")
local group = vim.api.nvim_create_augroup("wok.signature", { clear = true })

local win
local latest = 0

local function is_open()
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function close()
  if is_open() then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
end

-- Asks the servers for the signature at the cursor and shows it, or closes
-- the window when the cursor is no longer inside a call.
local function update(buf)
  latest = latest + 1
  local request = latest
  vim.lsp.buf_request_all(buf, "textDocument/signatureHelp", function(client)
    return util.make_position_params(0, client.offset_encoding)
  end, function(results)
    -- Ignore answers that a later keystroke or leaving insert mode replaced.
    if request ~= latest or vim.api.nvim_get_current_buf() ~= buf or not vim.fn.mode():find("^i") then
      return
    end
    for client_id, response in pairs(results) do
      local help = response.result
      local client = vim.lsp.get_client_by_id(client_id)
      if client and help and help.signatures and #help.signatures > 0 then
        local triggers = vim.tbl_get(client.server_capabilities, "signatureHelpProvider", "triggerCharacters")
        local lines, active = util.convert_signature_help_to_markdown_lines(help, vim.bo[buf].filetype, triggers)
        if lines and #lines > 0 then
          close()
          local float
          float, win = util.open_floating_preview(lines, "markdown", {
            focusable = false,
            anchor_bias = "above",
            close_events = { "InsertLeave", "BufLeave" },
          })
          if active then
            vim.hl.range(float, ns, "LspSignatureActiveParameter", { active[1], active[2] }, { active[3], active[4] })
          end
          return
        end
      end
    end
    close()
  end)
end


-- Trigger characters per buffer, from every attached server that offers
-- signatures.
local triggers = {}

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local provider = client.server_capabilities.signatureHelpProvider
    if not provider then
      return
    end
    local buf = args.buf
    local first = triggers[buf] == nil
    triggers[buf] = triggers[buf] or {}
    for _, char in ipairs(vim.list_extend(vim.deepcopy(provider.triggerCharacters or {}), provider.retriggerCharacters or {})) do
      triggers[buf][char] = true
    end
    if not first then
      return
    end
    vim.api.nvim_create_autocmd("InsertCharPre", {
      group = group,
      buffer = buf,
      callback = function()
        if triggers[buf][vim.v.char] or is_open() then
          -- Runs once the typed character is in the buffer.
          vim.schedule(function()
            update(buf)
          end)
        end
      end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
      group = group,
      buffer = buf,
      callback = function()
        triggers[buf] = nil
      end,
    })
  end,
})
