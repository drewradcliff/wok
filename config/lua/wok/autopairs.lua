-- Auto-closing brackets and quotes, a pair closes
-- only before whitespace, the end of the line, or closing punctuation; typing
-- the closer next to the cursor steps over it; Backspace in an empty pair
-- deletes both. Only in file buffers, so search prompts and terminals type
-- plainly.
local M = {}

local closers = { ["("] = ")", ["["] = "]", ["{"] = "}" }
local quotes = { ['"'] = true, ["'"] = true, ["`"] = true }
-- VS Code's autoCloseBefore: the characters a pair may close in front of.
local close_before = ";:.,=}])> \t\"'`"

-- <C-g>U keeps the cursor move inside the same undo step and dot-repeat.
local left, right = "<C-g>U<Left>", "<C-g>U<Right>"

local function enabled()
  return vim.bo.buftype == ""
end

-- The characters before and after the cursor.
local function around()
  local col = vim.fn.col(".")
  local line = vim.api.nvim_get_current_line()
  return line:sub(col - 1, col - 1), line:sub(col, col)
end

-- After a backslash a character is escaped, so it's typed as is.
local function active(prev)
  return enabled() and prev ~= "\\"
end

local function closes_here(next)
  return next == "" or close_before:find(next, 1, true) ~= nil
end

local function map(lhs, rhs)
  vim.keymap.set("i", lhs, rhs, { expr = true, replace_keycodes = true })
end

for open, close in pairs(closers) do
  map(open, function()
    local prev, next = around()
    return active(prev) and closes_here(next) and open .. close .. left or open
  end)
  map(close, function()
    local prev, next = around()
    return active(prev) and next == close and right or close
  end)
end

for quote in pairs(quotes) do
  map(quote, function()
    local prev, next = around()
    if not active(prev) then
      return quote
    end
    if next == quote then
      return right
    end
    -- After a word character it's an apostrophe or a closing quote.
    if prev:match("[%w_]") or prev == quote or not closes_here(next) then
      return quote
    end
    return quote .. quote .. left
  end)
end

map("<BS>", function()
  local prev, next = around()
  if enabled() and prev ~= "" and (closers[prev] == next or (quotes[prev] and prev == next)) then
    return "<BS><Del>"
  end
  return "<BS>"
end)

-- Keys for Enter between a bracket pair: puts the closer on its own line and
-- the cursor on an indented line between. nil anywhere else.
function M.enter()
  local prev, next = around()
  if enabled() and closers[prev] == next then
    return "<CR><C-o>O"
  end
end

return M
