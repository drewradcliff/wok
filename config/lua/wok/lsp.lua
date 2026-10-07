-- Errors, warnings, and types from language servers. Server definitions come
-- from nvim-lspconfig; each one starts only if its binary is installed.
local severity = vim.diagnostic.severity

-- circled x, triangle, circled i, lightbulb.
local icons = {
  [severity.ERROR] = "\u{F057}",
  [severity.WARN] = "\u{F071}",
  [severity.INFO] = "\u{F05A}",
  [severity.HINT] = "\u{F0EB}",
}

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  -- The gutter belongs to git change bars, so problem lines tint their number.
  signs = {
    text = { [severity.ERROR] = "", [severity.WARN] = "", [severity.INFO] = "", [severity.HINT] = "" },
    numhl = { [severity.ERROR] = "DiagnosticError", [severity.WARN] = "DiagnosticWarn" },
  },
  -- Hints stay quiet: unused code fades, the message is one ]d away.
  virtual_text = {
    severity = { min = severity.INFO },
    spacing = 2,
    source = "if_many",
    prefix = function(diagnostic)
      return icons[diagnostic.severity]
    end,
  },
  float = { source = "if_many", header = "" },
  jump = {
    on_jump = function(_, buf)
      vim.diagnostic.open_float({ bufnr = buf, scope = "cursor", focus = false })
    end,
  },
  status = {
    format = function(counts)
      local items = {}
      for _, level in ipairs({ severity.ERROR, severity.WARN }) do
        if counts[level] then
          local hl = level == severity.ERROR and "DiagnosticError" or "DiagnosticWarn"
          items[#items + 1] = ("%%$%s$%s %d"):format(hl, icons[level], counts[level])
        end
      end
      return table.concat(items, " ")
    end,
  },
})

-- Lua in this config is checked against the Neovim API and installed plugins.
local config_dir = vim.uv.fs_realpath(vim.fn.stdpath("config"))
local lua_ls = assert(vim.lsp.config.lua_ls)
vim.lsp.config("lua_ls", {
  root_dir = function(buf, on_dir)
    local file = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buf))
    if config_dir and file and vim.fs.relpath(config_dir, file) then
      return on_dir(config_dir)
    end
    on_dir(vim.fs.root(buf, lua_ls.root_markers))
  end,
  before_init = function(_, config)
    if config.root_dir ~= config_dir then
      return
    end
    local library = { vim.env.VIMRUNTIME }
    for _, plugin in ipairs(vim.pack.get()) do
      library[#library + 1] = plugin.path
    end
    config.settings.Lua = vim.tbl_deep_extend("force", config.settings.Lua or {}, {
      runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
      workspace = { checkThirdParty = false, library = library },
    })
  end,
})

-- clangd handles the C family, so SourceKit-LSP only takes Swift.
vim.lsp.config("sourcekit", { filetypes = { "swift" } })

-- basedpyright's default is stricter than most projects are typed for.
-- A pyproject.toml or pyrightconfig.json still takes precedence. The project's
-- virtualenv is used so installed packages resolve without activating it.
vim.lsp.config("basedpyright", {
  settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
  before_init = function(_, config)
    for _, venv in ipairs({ ".venv", "venv" }) do
      local python = config.root_dir and vim.fs.joinpath(config.root_dir, venv, "bin", "python")
      if python and vim.uv.fs_stat(python) then
        config.settings.python = vim.tbl_extend("force", config.settings.python or {}, { pythonPath = python })
        return
      end
    end
  end,
})

-- gopls shows no type hints unless asked.
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- TypeScript, like VS Code, follows the project's own version: TypeScript 7+
-- has a native server (tsc); older projects run theirs through vtsls.
local function project_typescript(buf)
  for dir in vim.fs.parents(vim.api.nvim_buf_get_name(buf)) do
    local pkg = dir .. "/node_modules/typescript/package.json"
    if vim.uv.fs_stat(pkg) then
      local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
      return ok and vim.version.parse(data.version) or nil
    end
  end
end

local global_typescript
local function installed_typescript()
  if global_typescript == nil then
    global_typescript = false
    if vim.fn.executable("tsc") == 1 then
      local out = vim.system({ "tsc", "--version" }, { text = true }):wait()
      global_typescript = vim.version.parse(out.stdout or "") or false
    end
  end
  return global_typescript or nil
end

local function native_typescript(buf)
  local version = project_typescript(buf) or installed_typescript()
  return version ~= nil and version.major >= 7
end

-- cmd and root_dir share lspconfig's binary cache, so both are kept from one load.
local tsc = assert(vim.lsp.config.tsc)
vim.lsp.config("tsc", {
  cmd = tsc.cmd,
  root_dir = function(buf, on_dir)
    if native_typescript(buf) then
      tsc.root_dir(buf, on_dir)
    end
  end,
})

local vtsls = assert(vim.lsp.config.vtsls)
local ts_hints = vim.tbl_get(tsc, "settings", "js/ts", "inlayHints")
vim.lsp.config("vtsls", {
  root_dir = function(buf, on_dir)
    if not native_typescript(buf) then
      vtsls.root_dir(buf, on_dir)
    end
  end,
  settings = {
    vtsls = { autoUseWorkspaceTsdk = true },
    typescript = { inlayHints = ts_hints },
    javascript = { inlayHints = ts_hints },
  },
})

require("wok.servers").setup()

vim.lsp.enable({
  "lua_ls",
  "tsc",
  "vtsls",
  "basedpyright",
  "ruff",
  "gopls",
  "rust_analyzer",
  "jsonls",
  "html",
  "cssls",
  "clangd",
  "sourcekit",
})

require("which-key").add({ { "<leader>t", group = "Toggle" } })
vim.keymap.set("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Type hints" })
