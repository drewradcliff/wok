-- wok: a thoughtfully configured Neovim.

-- wok is built on Neovim 0.12 (vim.pack, autocomplete, the new message UI).
-- On anything older, explain instead of failing partway through startup.
-- Only uses APIs that older versions have.
if vim.fn.has("nvim-0.12") == 0 then
  local version = vim.split(vim.fn.execute("version"), "\n", { trimempty = true })[1]
  vim.api.nvim_echo({
    { ("wok needs Neovim 0.12 or later, but %s is %s.\n"):format(vim.v.progpath, version), "ErrorMsg" },
    { "Upgrade it with `brew upgrade neovim`, or put Homebrew's nvim first on your PATH." },
  }, true, {})
  return
end

vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("wok.options")
vim.cmd.colorscheme("wok")
require("wok.highlights")
require("wok.plugins")
require("wok.keymaps")
require("wok.autocmds")

-- Your own settings live outside wok, so upgrades never touch them.
local user = vim.fs.joinpath(vim.env.XDG_CONFIG_HOME or vim.fs.normalize("~/.config"), "wok.lua")
if vim.uv.fs_stat(user) then
  dofile(user)
end
