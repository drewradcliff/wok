-- Language servers download in the background the first time a file needs
-- them. A server you installed yourself (in the project or on PATH)
-- always wins. Versions are pinned here and downloads are checksum-verified.
local M = {}

local root = vim.fs.joinpath(vim.fn.stdpath("data"), "servers")
local machine = vim.uv.os_uname().machine
local rust_arch = { arm64 = "aarch64", x86_64 = "x86_64" }
local node_arch = { arm64 = "arm64", x86_64 = "x64" }

-- What gets downloaded. Several servers can share one download.
local downloads = {
  node = {
    label = "Node.js",
    version = "24.21.0",
    url = "https://nodejs.org/dist/v{version}/node-v{version}-darwin-{arch}.tar.gz",
    arch = node_arch,
    strip = 1,
    sha256 = {
      arm64 = "bed7eea5325e1108f32ce5228ddd6a5f0f08a499ee42aa7442aea583702f6057",
      x86_64 = "1462cb3b3046b815cf8ea436d3da450ec1a9f11dac7e5a46b0ada5305d7e8097",
    },
  },
  vtsls = { label = "TypeScript", npm = "@vtsls/language-server", version = "0.3.0" },
  basedpyright = { label = "Python", npm = "basedpyright", version = "1.40.1" },
  langservers = { label = "JSON, HTML, and CSS", npm = "vscode-langservers-extracted", version = "4.10.0" },
  ruff = {
    label = "Python linting",
    version = "0.16.9",
    url = "https://github.com/astral-sh/ruff/releases/download/{version}/ruff-{arch}-apple-darwin.tar.gz",
    arch = rust_arch,
    strip = 1,
    sha256 = {
      arm64 = "33d35394499094cf6eb90f730dc82f11c0fab05d176378ae4f67de985ecc4146",
      x86_64 = "e98ea259a021c87d3a1f8bf18639d2e32dcd45cb2ef1afcb41b13e295de1e2b3",
    },
  },
  lua_ls = {
    label = "Lua",
    version = "3.19.1",
    url = "https://github.com/LuaLS/lua-language-server/releases/download/{version}/lua-language-server-{version}-darwin-{arch}.tar.gz",
    arch = node_arch,
    sha256 = {
      arm64 = "0bc077f4447f076b4c92c14e9fd303f5b569eda2ec74b4dca2b55f75fae2e90c",
      x86_64 = "eb373c159cbe556711d7cd316315de2dce969bfd54b31edb7eb9cab2937f2cca",
    },
  },
  rust_analyzer = {
    label = "Rust",
    version = "2026-09-28",
    url = "https://github.com/rust-lang/rust-analyzer/releases/download/{version}/rust-analyzer-{arch}-apple-darwin.gz",
    arch = rust_arch,
    file = "rust-analyzer",
    sha256 = {
      arm64 = "54ec873d8996e2c127d758bf45d4eacb6d3371dae4f6f6d5d3f05cedbae5fd59",
      x86_64 = "d032c0eb75e4597cc8ffc35ea4cdbd9eecc8341936b6edac6749e679fc3f0682",
    },
  },
  gopls = { label = "Go", go = "golang.org/x/tools/gopls", version = "v0.23.0" },
}

-- How each server runs. `path` is the command looked up in the project and on
-- PATH; otherwise `node` is a script run with Node, or `bin` a binary.
local servers = {
  vtsls = {
    download = "vtsls",
    path = "vtsls",
    node = "node_modules/@vtsls/language-server/bin/vtsls.js",
    args = { "--stdio" },
  },
  basedpyright = {
    download = "basedpyright",
    path = "basedpyright-langserver",
    node = "node_modules/basedpyright/langserver.index.js",
    args = { "--stdio" },
  },
  jsonls = {
    download = "langservers",
    path = "vscode-json-language-server",
    node = "node_modules/vscode-langservers-extracted/bin/vscode-json-language-server",
    args = { "--stdio" },
  },
  html = {
    download = "langservers",
    path = "vscode-html-language-server",
    node = "node_modules/vscode-langservers-extracted/bin/vscode-html-language-server",
    args = { "--stdio" },
  },
  cssls = {
    download = "langservers",
    path = "vscode-css-language-server",
    node = "node_modules/vscode-langservers-extracted/bin/vscode-css-language-server",
    args = { "--stdio" },
  },
  ruff = { download = "ruff", path = "ruff", bin = "ruff", args = { "server" } },
  lua_ls = { download = "lua_ls", path = "lua-language-server", bin = "bin/lua-language-server" },
  -- rustup puts a rust-analyzer on PATH even when the component isn't installed.
  rust_analyzer = {
    download = "rust_analyzer",
    path = "rust-analyzer",
    verify = true,
    bin = "rust-analyzer",
    requires = { cmd = "cargo", hint = "install Rust from rustup.rs" },
  },
  gopls = {
    download = "gopls",
    path = "gopls",
    bin = "gopls",
    requires = { cmd = "go", hint = "brew install go" },
  },
}

local function expand(template, spec)
  return (template:gsub("{(%w+)}", { version = spec.version, arch = spec.arch and spec.arch[machine] }))
end

local function installed(name)
  local dir = vim.fs.joinpath(root, name, downloads[name].version)
  return vim.uv.fs_stat(dir) and dir or nil
end

local system_node
local function find_node()
  if system_node == nil then
    system_node = false
    local exe = vim.fn.exepath("node")
    if exe ~= "" then
      local out = vim.system({ exe, "--version" }, { text = true }):wait()
      local version = vim.version.parse(out.stdout or "")
      if version and version.major >= 18 then
        system_node = exe
      end
    end
  end
  if system_node then
    return system_node
  end
  local dir = installed("node")
  return dir and vim.fs.joinpath(dir, "bin", "node") or nil
end

local works = {}
local function yours(server, project)
  if project then
    for _, dir in ipairs({ "node_modules/.bin", ".venv/bin", "venv/bin" }) do
      local exe = vim.fs.joinpath(project, dir, server.path)
      if vim.fn.executable(exe) == 1 then
        return exe
      end
    end
  end
  local exe = vim.fn.exepath(server.path)
  if exe == "" then
    return nil
  end
  if server.verify then
    if works[exe] == nil then
      works[exe] = vim.system({ exe, "--version" }):wait().code == 0
    end
    return works[exe] and exe or nil
  end
  return exe
end

local function command(name, project)
  local server = servers[name]
  local args = server.args or {}
  local exe = yours(server, project)
  if exe then
    return { exe, unpack(args) }
  end
  local dir = installed(server.download)
  if not dir then
    return nil
  end
  if server.node then
    local node = find_node()
    return node and { node, vim.fs.joinpath(dir, server.node), unpack(args) } or nil
  end
  return { vim.fs.joinpath(dir, expand(server.bin, downloads[server.download])), unpack(args) }
end

-- Runs a command from inside a coroutine and waits for it.
local function run(cmd, opts)
  local co = coroutine.running()
  vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {}), function(out)
    vim.schedule(function()
      coroutine.resume(co, out)
    end)
  end)
  local out = coroutine.yield()
  if out.code ~= 0 then
    local reason = vim.trim(out.stderr or "")
    error(reason ~= "" and reason or table.concat(cmd, " ") .. " failed", 0)
  end
  return out
end

local pending, failed = {}, {}
local await

local function fetch(spec, dir, step)
  if spec.npm then
    local node = find_node()
    if not node then
      await("node")
      node = assert(find_node())
    end
    local npm = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(vim.uv.fs_realpath(node)), "../lib/node_modules/npm/bin/npm-cli.js"))
    step(20)
    run({
      node, npm, "install", "--prefix", dir, "--no-package-lock", "--save-exact",
      "--no-fund", "--no-audit", "--loglevel=error", spec.npm .. "@" .. spec.version,
    }, { env = { PATH = vim.fs.dirname(node) .. ":" .. vim.env.PATH } })
  elseif spec.go then
    run({ "go", "install", spec.go .. "@" .. spec.version }, { env = { GOBIN = dir } })
  else
    local url = expand(spec.url, spec)
    local file = vim.fs.joinpath(dir, vim.fs.basename(url))
    run({ "curl", "-fsSL", "--retry", "2", "-o", file, url })
    step(60)
    local sum = run({ "shasum", "-a", "256", file }).stdout:match("^%x+")
    if sum ~= spec.sha256[machine] then
      error("the download didn't match its checksum", 0)
    end
    step(80)
    if file:match("%.tar%.gz$") then
      run({ "tar", "-xzf", file, "-C", dir, "--strip-components", tostring(spec.strip or 0) })
      os.remove(file)
    else
      run({ "gunzip", file })
      local bin = vim.fs.joinpath(dir, spec.file)
      assert(vim.uv.fs_rename((file:gsub("%.gz$", "")), bin))
      assert(vim.uv.fs_chmod(bin, tonumber("755", 8)))
    end
  end
end

-- Starts a download, or joins one in progress. on_done(ok) runs once it ends.
local function download(name, on_done)
  if failed[name] then
    return on_done(false)
  end
  if pending[name] then
    table.insert(pending[name], on_done)
    return
  end
  pending[name] = { on_done }

  local spec = downloads[name]
  local final = vim.fs.joinpath(root, name, spec.version)
  local dir = final .. ".partial"
  local message = ("Setting up %s…"):format(spec.label)
  local function progress(status, text, percent, hl)
    vim.api.nvim_echo({ { text, hl } }, status ~= "running", {
      kind = "progress",
      id = "wok.servers." .. name,
      source = "wok",
      title = "wok",
      status = status,
      percent = percent,
    })
  end

  coroutine.wrap(function()
    progress("running", message, 0)
    local ok, err = pcall(function()
      vim.fn.delete(dir, "rf")
      vim.fn.mkdir(dir, "p")
      fetch(spec, dir, function(percent)
        progress("running", message, percent)
      end)
      for entry in vim.fs.dir(vim.fs.dirname(final)) do
        if entry ~= vim.fs.basename(dir) then
          vim.fn.delete(vim.fs.joinpath(vim.fs.dirname(final), entry), "rf")
        end
      end
      assert(vim.uv.fs_rename(dir, final))
    end)
    if ok then
      progress("success", ("%s is ready"):format(spec.label))
    else
      failed[name] = true
      vim.fn.delete(dir, "rf")
      local reason = vim.split(tostring(err), "\n")[1]
      progress("failed", ("Couldn't set up %s; wok will try again next launch. %s"):format(spec.label, reason), nil, "ErrorMsg")
    end
    local callbacks = pending[name]
    pending[name] = nil
    for _, callback in ipairs(callbacks) do
      callback(ok)
    end
  end)()
end

-- Waits for a download from inside a coroutine.
function await(name)
  local co = coroutine.running()
  download(name, function(ok)
    vim.schedule(function()
      coroutine.resume(co, ok)
    end)
  end)
  if not coroutine.yield() then
    error(downloads[name].label .. " isn't available", 0)
  end
end

local function prepare(name)
  local server = servers[name]
  coroutine.wrap(function()
    local ok = pcall(function()
      if not installed(server.download) then
        await(server.download)
      end
      if server.node and not find_node() then
        await("node")
      end
    end)
    if ok then
      vim.lsp.enable(name)
    end
  end)()
end

-- Wraps a server's config so it starts from whichever copy is available, and
-- downloads one in the background when there's none yet.
local function manage(name)
  local server = servers[name]
  local config = assert(vim.lsp.config[name])
  local find_root = config.root_dir
  local markers = config.root_markers
  local label = downloads[server.download].label

  vim.lsp.config(name, {
    cmd = function(dispatchers, resolved)
      local cmd = assert(command(name, resolved.root_dir), name .. " isn't installed")
      return vim.lsp.rpc.start(cmd, dispatchers, { cwd = resolved.cmd_cwd, env = resolved.cmd_env })
    end,
    root_dir = function(buf, on_dir)
      local requires = server.requires
      if requires and vim.fn.executable(requires.cmd) == 0 then
        vim.notify_once(("%s support needs %s: %s"):format(label, requires.cmd, requires.hint), vim.log.levels.WARN)
        return
      end
      local function found(project)
        if command(name, project) then
          on_dir(project)
        else
          prepare(name)
        end
      end
      if type(find_root) == "function" then
        find_root(buf, function(project)
          vim.schedule(function()
            found(project)
          end)
        end)
      else
        found(markers and vim.fs.root(buf, markers) or nil)
      end
    end,
  })
end

function M.setup()
  for name in pairs(servers) do
    manage(name)
  end
end

return M
