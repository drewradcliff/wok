local get = function(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- Floats and popup menus sit on their own background, padded by a blank
-- border (see 'winborder'). The wok colorscheme already does this; the
-- fallback is for any other colorscheme, borrowing the cursor line color when
-- floats would otherwise blend into the editor.
local function apply()
  if vim.g.colors_name == "wok" then
    return
  end
  local normal = get("Normal").bg
  local function surface(name)
    local bg = get(name).bg
    return (bg and bg ~= normal) and bg or get("CursorLine").bg
  end

  local float = surface("NormalFloat")
  vim.api.nvim_set_hl(0, "NormalFloat", vim.tbl_extend("force", get("NormalFloat"), { bg = float }))
  vim.api.nvim_set_hl(0, "FloatBorder", vim.tbl_extend("force", get("FloatBorder"), { bg = float }))

  local menu = surface("Pmenu")
  vim.api.nvim_set_hl(0, "Pmenu", vim.tbl_extend("force", get("Pmenu"), { bg = menu }))
  vim.api.nvim_set_hl(0, "PmenuBorder", vim.tbl_extend("force", get("PmenuBorder"), { bg = menu }))
end

apply()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("wok.highlights", { clear = true }),
  desc = "Reapply wok float styling",
  callback = apply,
})
