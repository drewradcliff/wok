-- Syntax highlighting and folding from tree-sitter. Neovim ships parsers for
-- only a few languages; the rest download and compile in the background the
-- first time you open one (nvim-treesitter, built with tree-sitter-cli).
local treesitter = require("nvim-treesitter")

-- Progress shows as one message per install, like language servers, instead
-- of nvim-treesitter's message per step. Its errors still show.
require("nvim-treesitter.log").Logger.info = function() end

-- Unmaintained and unsupported parsers aren't installed automatically.
local available = {}
for _, tier in ipairs({ 1, 2 }) do
  for _, lang in ipairs(treesitter.get_available(tier)) do
    available[lang] = true
  end
end

-- Looks for the query file rather than calling vim.treesitter.query.get(),
-- which caches a missing query for the rest of the session.
local function ready(lang)
  local queries = vim.api.nvim_get_runtime_file(("queries/%s/highlights.scm"):format(lang), false)
  return #queries > 0 and vim.treesitter.language.add(lang) == true
end

local function progress(lang, status, text, hl)
  vim.api.nvim_echo({ { text, hl } }, status ~= "running", {
    kind = "progress",
    id = "wok.treesitter." .. lang,
    source = "wok",
    title = "wok",
    status = status,
  })
end

-- Starts highlighting and folding. Folds are set only where there's a parser:
-- Neovim never clears the fold state of a parserless buffer that's wiped
-- inside an autocmd (as codediff's are), and errors on it later.
local function start(buf, lang)
  if not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].foldmethod = "expr"
    vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end
end

local pending, failed = {}, {}

-- Installs parsers, then restarts highlighting in every buffer that was
-- waiting for one. Languages already installing just add the buffer.
-- Returns whether the buffer is now waiting.
local function install(langs, buf)
  if vim.fn.executable("tree-sitter") == 0 then
    vim.notify_once("Syntax highlighting needs tree-sitter: brew install tree-sitter-cli", vim.log.levels.WARN)
    return false
  end
  local waiting, todo = false, {}
  for _, lang in ipairs(langs) do
    if pending[lang] then
      table.insert(pending[lang], buf)
      waiting = true
    elseif not failed[lang] then
      pending[lang] = { buf }
      table.insert(todo, lang)
      waiting = true
    end
  end
  if #todo == 0 then
    return waiting
  end

  local names = table.concat(todo, ", ")
  local id = table.concat(todo, ",")
  progress(id, "running", ("Setting up %s highlighting…"):format(names))
  treesitter.install(todo):await(function()
    vim.schedule(function()
      local bufs, broken = {}, {}
      for _, lang in ipairs(todo) do
        for _, b in ipairs(pending[lang]) do
          bufs[b] = true
        end
        pending[lang] = nil
        if not ready(lang) then
          failed[lang] = true
          table.insert(broken, lang)
        end
      end
      if #broken > 0 then
        local message = "Couldn't set up %s highlighting. wok will try again next launch."
        progress(id, "failed", message:format(table.concat(broken, ", ")), "ErrorMsg")
      else
        progress(id, "success", ("%s highlighting is ready"):format(names))
      end
      for b in pairs(bufs) do
        if vim.api.nvim_buf_is_loaded(b) then
          -- Setting the filetype again starts highlighting (see the FileType
          -- autocmd below) and clears the folds Neovim cached without a parser.
          vim.bo[b].filetype = vim.bo[b].filetype
          for _, win in ipairs(vim.fn.win_findbuf(b)) do
            vim.api.nvim_win_call(win, function()
              vim.cmd("normal! zx")
            end)
          end
        end
      end
    end)
  end)
  return true
end

-- Matches how Neovim resolves an injected language's name to a parser.
local function resolve(name)
  name = name:gsub("%s+", ""):lower():gsub("%-", "_")
  if available[name] then
    return name
  end
  local lang = vim.treesitter.language.get_lang(name)
  return available[lang] and lang or nil
end

-- Languages embedded in the buffer that have no parser yet: JSDoc in
-- comments, CSS in styled components, code blocks in Markdown, and so on.
local function missing_injections(buf, lang)
  local ok, query = pcall(vim.treesitter.query.get, lang, "injections")
  local parser = vim.treesitter.get_parser(buf, lang, { error = false })
  if not (ok and query and parser) then
    return {}
  end
  local found = {}
  local function add(name)
    local injected = name and resolve(name)
    if injected and not ready(injected) then
      found[injected] = true
    end
  end
  local root = parser:parse()[1]:root()
  for _, match, metadata in query:iter_matches(root, buf) do
    add(metadata["injection.language"])
    for id, nodes in pairs(match) do
      add(metadata[id] and metadata[id]["injection.language"])
      if query.captures[id] == "injection.language" then
        add(vim.treesitter.get_node_text(nodes[1], buf))
      end
    end
  end
  return vim.tbl_keys(found)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("wok.treesitter", { clear = true }),
  desc = "Use tree-sitter highlighting, installing parsers if needed",
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end
    if ready(lang) then
      -- Once highlighting looks for an embedded language's parser, Neovim
      -- remembers a missing one until it restarts. So install those first and
      -- start highlighting when they're ready (the regex syntax shows meanwhile).
      local missing = missing_injections(args.buf, lang)
      if #missing == 0 or not install(missing, args.buf) then
        start(args.buf, lang)
      end
    elseif available[lang] then
      install({ lang }, args.buf)
    end
  end,
})
