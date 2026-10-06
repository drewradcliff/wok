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
