-- Formatting with the project's own formatter: Prettier when the project
-- installs it, otherwise the language server. Saving formats only when the
-- formatter is the language's universal one (gofmt, rustfmt) or the project
-- sets one up, so a save never reformats a whole file in a project that
-- doesn't use one.
vim.g.wok_format_on_save = true

local prettier_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  vue = true,
  svelte = true,
  json = true,
  jsonc = true,
  json5 = true,
  css = true,
  scss = true,
  less = true,
  html = true,
  markdown = true,
  yaml = true,
  graphql = true,
}

local function prettier(buf)
  if not prettier_filetypes[vim.bo[buf].filetype] then
    return nil
  end
  for dir in vim.fs.parents(vim.api.nvim_buf_get_name(buf)) do
    local exe = vim.fs.joinpath(dir, "node_modules", ".bin", "prettier")
    if vim.fn.executable(exe) == 1 then
      return exe, dir
    end
  end
end

local function pyproject_has(buf, pattern)
  local root = vim.fs.root(buf, "pyproject.toml")
  if not root then
    return false
  end
  local lines = vim.fn.readfile(vim.fs.joinpath(root, "pyproject.toml"))
  return vim.iter(lines):any(function(line)
    return line:find(pattern) ~= nil
  end)
end

-- Which language server formats each language, and whether saving formats.
local servers = {
  go = { name = "gopls", on_save = true },
  rust = { name = "rust_analyzer", on_save = true },
  python = {
    name = "ruff",
    -- ruff format is Black-compatible, so a Black project gets the same result.
    on_save = function(buf)
      return vim.fs.root(buf, { "ruff.toml", ".ruff.toml" }) ~= nil
        or pyproject_has(buf, "^%[tool%.ruff")
        or pyproject_has(buf, "^%[tool%.black%]")
    end,
  },
  -- Without a .clang-format, clangd would apply LLVM's style.
  c = { name = "clangd", on_save = { ".clang-format", "_clang-format" } },
  cpp = { name = "clangd", on_save = { ".clang-format", "_clang-format" } },
  objc = { name = "clangd", on_save = { ".clang-format", "_clang-format" } },
}

-- Replaces only the lines that changed, so the cursor, marks, and folds
-- elsewhere stay put.
local function apply(buf, formatted)
  local old = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local new = vim.split(formatted, "\n", { plain = true })
  if new[#new] == "" then
    table.remove(new)
  end
  local hunks = vim.text.diff(table.concat(old, "\n") .. "\n", table.concat(new, "\n") .. "\n", {
    result_type = "indices",
    algorithm = "histogram",
  }) --[[@as integer[][] ]]
  for i = #hunks, 1, -1 do
    local start_a, count_a, start_b, count_b = unpack(hunks[i])
    local lines = vim.list_slice(new, start_b, start_b + count_b - 1)
    local first = count_a == 0 and start_a or start_a - 1
    vim.api.nvim_buf_set_lines(buf, first, first + count_a, false, lines)
  end
end

local function run_prettier(buf, exe, root)
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  local cmd = { exe, "--stdin-filepath", vim.api.nvim_buf_get_name(buf) }
  local out = vim.system(cmd, { stdin = text, cwd = root, text = true }):wait(5000)
  if out.code ~= 0 then
    -- Prettier prefixes each error with "[error] /path/to/file: ".
    local reason = vim.split(vim.trim(out.stderr or ""), "\n")[1]:gsub("^%[error%] [^:]+: ", "")
    vim.notify("Prettier couldn't format this file: " .. (reason ~= "" and reason or "it timed out"), vim.log.levels.WARN)
    return
  end
  if out.stdout ~= text then
    apply(buf, out.stdout)
  end
end

local function run_server(buf, name)
  local clients = vim.lsp.get_clients({ bufnr = buf, name = name, method = "textDocument/formatting" })
  if #clients == 0 then
    return false
  end
  vim.lsp.buf.format({ bufnr = buf, id = clients[1].id, timeout_ms = 3000 })
  return true
end

-- Formats with Prettier or the language's formatter; with neither, any
-- language server that can format.
local function format(buf)
  local exe, root = prettier(buf)
  if exe then
    return run_prettier(buf, exe, root)
  end
  local server = servers[vim.bo[buf].filetype]
  if server and run_server(buf, server.name) then
    return
  end
  if #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" }) == 0 then
    vim.notify("No formatter for this file", vim.log.levels.WARN)
    return
  end
  vim.lsp.buf.format({ bufnr = buf, timeout_ms = 3000 })
end

local function formats_on_save(buf)
  if prettier(buf) then
    return true
  end
  local server = servers[vim.bo[buf].filetype]
  local on_save = server and server.on_save
  if type(on_save) == "function" then
    return on_save(buf)
  elseif type(on_save) == "table" then
    return vim.fs.root(buf, on_save) ~= nil
  end
  return on_save == true
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("wok.format", { clear = true }),
  desc = "Format on save with the project's formatter",
  callback = function(args)
    if not vim.g.wok_format_on_save or not formats_on_save(args.buf) then
      return
    end
    local exe, root = prettier(args.buf)
    if exe then
      run_prettier(args.buf, exe, root)
    else
      -- The server may still be starting; the file saves unformatted.
      run_server(args.buf, servers[vim.bo[args.buf].filetype].name)
    end
  end,
})

require("which-key").add({ { "<leader>c", group = "Code" } })
vim.keymap.set("n", "<leader>cf", function()
  format(vim.api.nvim_get_current_buf())
end, { desc = "Format file" })
vim.keymap.set("n", "<leader>tf", function()
  vim.g.wok_format_on_save = not vim.g.wok_format_on_save
  vim.notify(("Format on save %s"):format(vim.g.wok_format_on_save and "on" or "off"))
end, { desc = "Format on save" })
