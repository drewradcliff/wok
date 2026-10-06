-- wok: a thoughtfully configured Neovim.

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
