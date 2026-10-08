local gh = function(repo)
  return "https://github.com/" .. repo
end

-- Revisions are pinned in nvim-pack-lock.json and ship with each wok release.
vim.pack.add({
  gh("folke/snacks.nvim"),
  gh("folke/which-key.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("esmuellert/codediff.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("nvim-treesitter/nvim-treesitter"),
}, { confirm = false })

-- vim.pack only reads the lockfile when it first installs a plugin, so after a
-- wok upgrade, move installed plugins to the revisions this release pins.
-- Runs before any plugin code is required, so the new revisions load.
-- Returns the plugins it moved.
local function sync_plugins()
  local lock = vim.fs.joinpath(vim.fn.stdpath("config"), "nvim-pack-lock.json")
  local dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
  local outdated = {}
  for name, plugin in pairs(vim.json.decode(table.concat(vim.fn.readfile(lock), "\n")).plugins) do
    -- vim.pack checks out exact commits, so HEAD holds the plugin's revision.
    local head = vim.fs.joinpath(dir, name, ".git", "HEAD")
    if vim.uv.fs_stat(head) and vim.fn.readfile(head)[1] ~= plugin.rev then
      table.insert(outdated, name)
    end
  end
  if #outdated > 0 then
    vim.pack.update(outdated, { target = "lockfile", force = true })
  end
  return outdated
end
local synced = sync_plugins()

require("which-key").setup({ preset = "helix" })
require("wok.picker")
require("wok.git")
require("wok.lsp")
require("wok.treesitter")

-- Parsers are pinned by nvim-treesitter, so rebuild any that its new revision
-- moved. Runs in the background. Open buffers keep the old parser until relaunch.
if vim.list_contains(synced, "nvim-treesitter") then
  require("nvim-treesitter").update()
end
