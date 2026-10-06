-- thin change bars in the gutter with per-change actions
-- (gitsigns), and a side-by-side review workspace (codediff).
local gitsigns = require("gitsigns")

local bar = { text = "▎" }
local signs = {
  add = bar,
  change = bar,
  changedelete = bar,
  untracked = bar,
  delete = { text = "▁" },
  topdelete = { text = "▔" },
}

local function map(mode, lhs, rhs, desc, buf)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = buf })
end

-- Acts on the selected lines in visual mode, the change under the cursor otherwise.
local function on_change(action)
  return function()
    if vim.fn.mode():find("^[vV\22]") then
      gitsigns[action]({ vim.fn.line("."), vim.fn.line("v") })
    else
      gitsigns[action]()
    end
  end
end

gitsigns.setup({
  signs = signs,
  signs_staged = signs,
  on_attach = function(buf)
    -- ]c / [c jump between changes; diff windows keep the built-in behavior.
    for key, direction in pairs({ ["]c"] = "next", ["[c"] = "prev" }) do
      map("n", key, function()
        if vim.wo.diff then
          vim.cmd.normal({ key, bang = true })
        else
          gitsigns.nav_hunk(direction)
        end
      end, direction == "next" and "Next change" or "Previous change", buf)
    end

    map("n", "<leader>gp", gitsigns.preview_hunk_inline, "Preview change", buf)
    map({ "n", "x" }, "<leader>ga", on_change("stage_hunk"), "Stage change", buf)
    map({ "n", "x" }, "<leader>gr", on_change("reset_hunk"), "Revert change", buf)
    map("n", "<leader>gB", function()
      gitsigns.blame_line({ full = true })
    end, "Blame line", buf)
    map({ "o", "x" }, "ih", gitsigns.select_hunk, "Change", buf)
  end,
})

require("codediff").setup({
  diff = {
    layout = "inline",
    compact = true,
  },
})

map("n", "<leader>gd", "<Cmd>CodeDiff<CR>", "Review changes")
map("n", "<leader>gf", "<Cmd>CodeDiff history %<CR>", "File history")
