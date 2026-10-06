-- Quick-open pickers use a compact search panel; the rest show a preview.
local quick = { smart = true, files = true, git_files = true, recent = true, buffers = true }

-- Opening a directory (`wok .`) cds into it and starts on an empty buffer
-- instead of netrw or the explorer.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0) --[[@as string]]
    if vim.fn.argc() == 1 and vim.fn.isdirectory(arg) == 1 then
      local dir_buf = vim.api.nvim_get_current_buf()
      vim.cmd.cd(arg)
      vim.cmd.enew()
      vim.api.nvim_buf_delete(dir_buf, { force = true })
    end
  end,
})

require("snacks").setup({
  -- Keep the explorer closed on startup; toggle it with its keymap.
  explorer = { replace_netrw = false },

  picker = {
    prompt = "󰍉 ",
    layout = {
      preset = function(source)
        if quick[source] then
          return "spotlight"
        end
        return vim.o.columns >= 120 and "default" or "vertical"
      end,
    },
    layouts = {
      spotlight = {
        hidden = { "preview" },
        layout = {
          backdrop = false,
          row = 0.15,
          width = 0.5,
          min_width = 72,
          max_width = 110,
          height = 0.5,
          min_height = 12,
          box = "vertical",
          border = true,
          title = "{title} {live} {flags}",
          title_pos = "center",
          { win = "input", height = 1, border = "bottom" },
          { win = "list", border = "none" },
          { win = "preview", title = "{preview}", height = 0.5, border = "top" },
        },
      },
      default = { layout = { backdrop = false } },
    },
    formatters = {
      file = { filename_first = true },
    },
    icons = {
      tree = { vertical = "  ", middle = "  ", last = "  " },
    },
    win = {
      input = {
        keys = { ["<Esc>"] = { "close", mode = { "n", "i" } } },
        bo = { autocomplete = false },
      },
    },
    sources = {
      smart = {
        title = "Files",
        multi = { "buffers", { source = "recent", filter = { cwd = true } }, "files" },
      },
      buffers = {
        filter = {
          filter = function(item)
            return item.name ~= "" or item.info.changed == 1
          end,
        },
      },
      recent = {
        -- Old sessions can leave directories in v:oldfiles.
        filter = {
          filter = function(item)
            return vim.fn.isdirectory(item.file) == 0
          end,
        },
      },
      explorer = {
        -- Stays out of the way until you press / to filter.
        layout = { auto_hide = { "input" }, layout = { width = 32, min_width = 32 } },
      },
    },
  },
})

local function pick(source, opts)
  return function()
    Snacks.picker[source](opts)
  end
end

-- Without ripgrep the grep pickers silently find nothing.
local function grep(source)
  return function()
    if vim.fn.executable("rg") == 0 then
      vim.notify("Project search needs ripgrep: brew install ripgrep", vim.log.levels.WARN)
      return
    end
    Snacks.picker[source]()
  end
end

require("which-key").add({
  { "<leader>f", group = "Find" },
  { "<leader>s", group = "Search" },
  { "<leader>g", group = "Git" },
})

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map("n", "<leader><space>", pick("smart"), "Find files")
map("n", "<D-p>", pick("smart"), "Find files")
map("n", "<leader>/", grep("grep"), "Search in project")
map("n", "<leader>,", pick("buffers"), "Switch buffer")
map("n", "<leader>e", function()
  Snacks.explorer()
end, "Toggle file explorer")

-- Find
map("n", "<leader>ff", pick("files"), "Files")
map("n", "<leader>fr", pick("recent"), "Recent files")
map("n", "<leader>fb", pick("buffers"), "Buffers")
map("n", "<leader>fg", pick("git_files"), "Git files")
map("n", "<leader>fc", pick("files", { cwd = vim.fn.stdpath("config") }), "Config files")

-- Search
map({ "n", "x" }, "<leader>sw", grep("grep_word"), "Word or selection")
map("n", "<leader>sb", pick("lines"), "Lines in buffer")
map("n", "<leader>sh", pick("help"), "Help")
map("n", "<leader>sk", pick("keymaps"), "Keymaps")
map("n", "<leader>sc", pick("commands"), "Commands")
map("n", "<leader>sd", pick("diagnostics"), "Diagnostics")
map("n", "<leader>ss", pick("lsp_workspace_symbols"), "Workspace symbols")
map("n", "<leader>su", pick("undo"), "Undo history")
map("n", "<leader>sr", pick("resume"), "Resume last picker")

-- Git
map("n", "<leader>gs", pick("git_status"), "Git status")
map("n", "<leader>gl", pick("git_log"), "Git log")
map("n", "<leader>gb", pick("git_branches"), "Git branches")

-- LSP: gd plus the built-in mappings, shown in the picker.
map("n", "gd", pick("lsp_definitions"), "Definition")
map("n", "grr", pick("lsp_references"), "References")
map("n", "gri", pick("lsp_implementations"), "Implementations")
map("n", "grt", pick("lsp_type_definitions"), "Type definitions")
map("n", "gO", pick("lsp_symbols"), "Document symbols")
