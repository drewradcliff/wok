local group = vim.api.nvim_create_augroup("wok", { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

autocmd("TextYankPost", {
  desc = "Briefly highlight yanked text",
  callback = function()
    vim.hl.on_yank()
  end,
})

autocmd("FileType", {
  desc = "Use treesitter highlighting when a parser is available",
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

autocmd("CmdlineChanged", {
  desc = "Show command-line completions as you type",
  pattern = ":",
  callback = function()
    vim.fn.wildtrigger()
  end,
})

autocmd("BufReadPost", {
  desc = "Reopen files where you left off",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[args.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Pick up changes made outside Neovim",
  command = "checktime",
})

autocmd("VimResized", {
  desc = "Keep splits balanced when the terminal resizes",
  command = "tabdo wincmd =",
})

autocmd("BufWritePre", {
  desc = "Create missing parent directories on save",
  callback = function(args)
    if args.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(args.match) or args.match, ":p:h"), "p")
  end,
})

autocmd("FileType", {
  desc = "Close transient windows with q",
  pattern = { "help", "qf", "man", "checkhealth", "nvim-pack" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = args.buf, silent = true })
  end,
})
