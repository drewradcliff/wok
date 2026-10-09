local map = vim.keymap.set

map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move by visual line when wrapping, unless a count is given.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Save like every other app.
map({ "n", "i", "x" }, "<C-s>", "<Cmd>write<CR><Esc>", { desc = "Save" })
map({ "n", "i", "x" }, "<D-s>", "<Cmd>write<CR><Esc>", { desc = "Save" })

-- Delete a word or to the start of the line like other apps.
map({ "i", "c" }, "<M-BS>", "<C-w>", { desc = "Delete word" })
map({ "i", "c" }, "<C-BS>", "<C-w>", { desc = "Delete word" })
map({ "i", "c" }, "<D-BS>", "<C-u>", { desc = "Delete to start of line" })

-- Tab or Enter accepts the highlighted completion, like VS Code. With nothing
-- highlighted they type as usual, and Tab still jumps through snippet fields.
local function completion_selected()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1
end
map("i", "<Tab>", function()
  if completion_selected() then
    return "<C-y>"
  elseif vim.snippet.active({ direction = 1 }) then
    return "<Cmd>lua vim.snippet.jump(1)<CR>"
  end
  return "<Tab>"
end, { expr = true, desc = "Accept completion" })
map("i", "<CR>", function()
  if completion_selected() then
    return "<C-y>"
  end
  return require("wok.autopairs").enter() or "<CR>"
end, { expr = true, desc = "Accept completion" })

map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- Keep the selection when indenting.
map("x", "<", "<gv")
map("x", ">", ">gv")

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keep history navigation on <Up>/<Down> while the completion menu is open.
for _, key in ipairs({ "<Up>", "<Down>" }) do
  map("c", key, function()
    return vim.fn.wildmenumode() == 1 and "<C-e>" .. key or key
  end, { expr = true })
end
