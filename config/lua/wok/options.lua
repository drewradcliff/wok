local opt = vim.opt

-- Messages & command line: no "Press ENTER" prompts.
require("vim._core.ui2").enable({})

-- Interface
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.laststatus = 3
opt.winborder = "rounded"
opt.pumborder = "rounded"
opt.pumheight = 10
opt.fillchars = { eob = " ", fold = " " }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.shortmess:append("I")

-- Behaves like a native editor: mouse, system clipboard, ask instead of error.
opt.mouse = "a"
opt.confirm = true
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

-- Scrolling & wrapping
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

-- Windows
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Files: persistent undo instead of swap-file warnings.
opt.undofile = true
opt.swapfile = false

-- Responsiveness
opt.updatetime = 250
opt.timeoutlen = 400

-- Insert-mode completion appears as you type, with the first match highlighted
-- Tab or Enter accepts it
opt.autocomplete = true
opt.complete = ".,w,b,u"
opt.completeopt = { "menuone", "noinsert", "popup", "fuzzy" }

-- Command-line completion appears as you type (see autocmds).
opt.wildmode = "noselect:lastused,full"
opt.wildoptions = { "pum", "fuzzy" }

-- Folding: treesitter-aware, everything open by default.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevelstart = 99

-- Editing
opt.virtualedit = "block"
opt.diffopt:append("algorithm:histogram")
