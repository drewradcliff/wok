--
-- Light and dark variants follow 'background', which Neovim detects from the
-- terminal and updates live when the terminal switches appearance.

vim.cmd.highlight("clear")
vim.g.colors_name = "wok"

local palettes = {
  light = {
    bg = "#FFFFFF",
    fg = "#262626",
    secondary = "#8A8A8E",
    tertiary = "#C4C4C7",
    gutter = "#A6A6AB",
    surface = "#F2F2F7",
    line = "#ECF5FF",
    selection = "#B3D7FF",
    separator = "#C6C6C8",
    border = "#C7C7CC",
    accent = "#007AFF",
    on_accent = "#FFFFFF",

    -- Darker variants so text stays legible on white.
    red = "#D70015",
    orange = "#C93400",
    yellow = "#B25000",
    green = "#248A3D",
    teal = "#0071A4",
    blue = "#0040DD",
    purple = "#8944AB",
    find = "#FFCC00",

    comment = "#5D6C79",
    string = "#C41A16",
    number = "#1C00CF",
    keyword = "#9B2393",
    preproc = "#643820",
    url = "#0E0EFF",
    attribute = "#815F03",
    type_decl = "#0B4F79",
    other_decl = "#0F68A0",
    type = "#1C464A",
    func = "#326D74",
    lib_type = "#3900A0",
    lib_func = "#6C36A9",

    ansi = {
      "#1C1C1E", "#D70015", "#248A3D", "#B25000", "#0040DD", "#8944AB", "#0071A4", "#D1D1D6",
      "#8E8E93", "#FF3B30", "#34C759", "#FF9500", "#007AFF", "#AF52DE", "#30B0C7", "#F2F2F7",
    },
  },

  dark = {
    bg = "#1F1F24",
    fg = "#DFDFE0",
    secondary = "#999AA1",
    tertiary = "#5C5C63",
    gutter = "#747478",
    surface = "#2C2C31",
    line = "#23252B",
    selection = "#3F638B",
    separator = "#3F3F43",
    border = "#48484A",
    accent = "#0A84FF",
    on_accent = "#FFFFFF",

    red = "#FF453A",
    orange = "#FF9F0A",
    yellow = "#FFD60A",
    green = "#30D158",
    teal = "#40C8E0",
    blue = "#0A84FF",
    purple = "#BF5AF2",
    find = "#FFD60A",

    comment = "#6C7986",
    string = "#FC6A5D",
    number = "#D0BF69",
    keyword = "#FC5FA3",
    preproc = "#FD8F3F",
    url = "#5482FF",
    attribute = "#BF8555",
    type_decl = "#5DD8FF",
    other_decl = "#41A1C0",
    type = "#9EF1DD",
    func = "#67B7A4",
    lib_type = "#D0A8FF",
    lib_func = "#A167E6",

    ansi = {
      "#2C2C2E", "#FF453A", "#30D158", "#FFD60A", "#0A84FF", "#BF5AF2", "#40C8E0", "#AEAEB2",
      "#636366", "#FF6961", "#30DB5B", "#FFD426", "#409CFF", "#DA8FFF", "#5DE6FF", "#FFFFFF",
    },
  },
}

local c = palettes[vim.o.background] or palettes.dark

-- Mixes `color` over the editor background, like a translucent system fill.
local function tint(color, alpha)
  local function channel(hex, i)
    return tonumber(hex:sub(i, i + 1), 16)
  end
  local out = "#"
  for i = 2, 6, 2 do
    local mixed = channel(color, i) * alpha + channel(c.bg, i) * (1 - alpha)
    out = out .. string.format("%02X", math.floor(mixed + 0.5))
  end
  return out
end

local groups = {
  -- Editor
  Normal = { fg = c.fg, bg = c.bg },
  NormalFloat = { fg = c.fg, bg = c.bg },
  FloatBorder = { fg = c.border, bg = c.bg },
  FloatTitle = { fg = c.fg, bg = c.bg, bold = true },
  FloatFooter = { fg = c.secondary, bg = c.bg },
  Cursor = { fg = c.bg, bg = c.fg },
  lCursor = { link = "Cursor" },
  CursorIM = { link = "Cursor" },
  TermCursor = { reverse = true },
  CursorLine = { bg = c.line },
  CursorColumn = { bg = c.line },
  ColorColumn = { bg = c.line },
  LineNr = { fg = c.gutter },
  CursorLineNr = { fg = c.fg },
  SignColumn = {},
  FoldColumn = { fg = c.gutter },
  Folded = { fg = c.secondary, bg = c.surface },
  NonText = { fg = c.tertiary },
  EndOfBuffer = { fg = c.bg },
  Whitespace = { fg = c.tertiary },
  SpecialKey = { fg = c.tertiary },
  Conceal = { fg = c.secondary },
  Visual = { bg = c.selection },
  VisualNOS = { bg = c.selection },
  Search = { bg = tint(c.find, 0.35) },
  CurSearch = { fg = "#1C1C1E", bg = c.find },
  IncSearch = { link = "CurSearch" },
  Substitute = { link = "CurSearch" },
  MatchParen = { bg = tint(c.accent, 0.25), bold = true },
  QuickFixLine = { bg = c.line, bold = true },
  Directory = { fg = c.accent },
  Title = { fg = c.fg, bold = true },

  -- Menus: selected rows use the accent fill.
  Pmenu = { fg = c.fg, bg = c.bg },
  PmenuBorder = { fg = c.border, bg = c.bg },
  PmenuSel = { fg = c.on_accent, bg = c.accent },
  PmenuKind = { fg = c.secondary, bg = c.bg },
  PmenuKindSel = { fg = c.on_accent, bg = c.accent },
  PmenuExtra = { fg = c.secondary, bg = c.bg },
  PmenuExtraSel = { fg = c.on_accent, bg = c.accent },
  PmenuMatch = { fg = c.fg, bg = c.bg, bold = true },
  PmenuMatchSel = { fg = c.on_accent, bg = c.accent, bold = true },
  PmenuSbar = { bg = c.bg },
  PmenuThumb = { bg = c.border },
  WildMenu = { link = "PmenuSel" },
  ComplHint = { fg = c.tertiary },
  ComplHintMore = { fg = c.secondary },
  PreInsert = { fg = c.tertiary },

  -- Bars
  StatusLine = { fg = c.secondary, bg = c.surface },
  StatusLineNC = { fg = c.tertiary, bg = c.surface },
  StatusLineTerm = { link = "StatusLine" },
  StatusLineTermNC = { link = "StatusLineNC" },
  TabLine = { fg = c.secondary, bg = c.surface },
  TabLineFill = { bg = c.surface },
  TabLineSel = { fg = c.fg, bg = c.bg, bold = true },
  WinBar = { fg = c.secondary, bg = c.bg },
  WinBarNC = { fg = c.tertiary, bg = c.bg },
  WinSeparator = { fg = c.separator },

  -- Messages
  ModeMsg = { fg = c.secondary, bold = true },
  MoreMsg = { fg = c.accent },
  Question = { fg = c.accent },
  ErrorMsg = { fg = c.red },
  WarningMsg = { fg = c.yellow },
  OkMsg = { fg = c.green },
  StderrMsg = { link = "ErrorMsg" },
  MsgSeparator = { fg = c.separator, bg = c.bg },

  -- Diffs and version control
  DiffAdd = { bg = tint(c.green, 0.15) },
  DiffChange = { bg = tint(c.blue, 0.10) },
  DiffText = { bg = tint(c.blue, 0.28) },
  DiffTextAdd = { bg = tint(c.green, 0.30) },
  DiffDelete = { fg = tint(c.red, 0.6), bg = tint(c.red, 0.12) },
  Added = { fg = c.green },
  Changed = { fg = c.accent },
  Removed = { fg = c.red },

  -- Spelling
  SpellBad = { undercurl = true, sp = c.red },
  SpellCap = { undercurl = true, sp = c.blue },
  SpellLocal = { undercurl = true, sp = c.teal },
  SpellRare = { undercurl = true, sp = c.purple },

  -- Diagnostics: inline messages sit on a tinted banner.
  DiagnosticError = { fg = c.red },
  DiagnosticWarn = { fg = c.yellow },
  DiagnosticInfo = { fg = c.blue },
  DiagnosticHint = { fg = c.secondary },
  DiagnosticOk = { fg = c.green },
  DiagnosticVirtualTextError = { fg = c.red, bg = tint(c.red, 0.12) },
  DiagnosticVirtualTextWarn = { fg = c.yellow, bg = tint(c.yellow, 0.12) },
  DiagnosticVirtualTextInfo = { fg = c.blue, bg = tint(c.blue, 0.12) },
  DiagnosticVirtualTextHint = { fg = c.secondary, bg = c.surface },
  DiagnosticVirtualTextOk = { fg = c.green, bg = tint(c.green, 0.12) },
  DiagnosticUnderlineError = { undercurl = true, sp = c.red },
  DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
  DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
  DiagnosticUnderlineHint = { undercurl = true, sp = c.secondary },
  DiagnosticUnderlineOk = { undercurl = true, sp = c.green },
  DiagnosticUnnecessary = { fg = c.secondary },
  DiagnosticDeprecated = { strikethrough = true, sp = c.secondary },

  -- LSP
  LspReferenceText = { bg = tint(c.fg, 0.10) },
  LspReferenceRead = { link = "LspReferenceText" },
  LspReferenceWrite = { link = "LspReferenceText" },
  LspInlayHint = { fg = c.secondary, bg = c.surface },
  LspCodeLens = { fg = c.secondary },
  LspSignatureActiveParameter = { fg = c.accent, bold = true },
  SnippetTabstop = { bg = tint(c.accent, 0.15) },
  SnippetTabstopActive = { bg = tint(c.accent, 0.30) },

  -- Syntax (legacy groups, for filetypes without a treesitter parser)
  Comment = { fg = c.comment },
  Constant = { fg = c.func },
  String = { fg = c.string },
  Character = { fg = c.number },
  Number = { fg = c.number },
  Float = { fg = c.number },
  Boolean = { fg = c.keyword, bold = true },
  Identifier = { fg = c.fg },
  Function = { fg = c.func },
  Statement = { fg = c.keyword, bold = true },
  Operator = { fg = c.fg },
  PreProc = { fg = c.preproc },
  Include = { fg = c.keyword, bold = true },
  Type = { fg = c.lib_type },
  StorageClass = { fg = c.keyword, bold = true },
  Structure = { fg = c.keyword, bold = true },
  Special = { fg = c.number },
  Tag = { fg = c.keyword },
  Delimiter = { fg = c.fg },
  SpecialComment = { fg = c.comment, bold = true },
  Underlined = { underline = true },
  Ignore = { fg = c.tertiary },
  Error = { fg = c.red },
  Todo = { fg = c.comment, bold = true },

  -- Treesitter. Definitions and references get separate colors, and
  -- standard-library names get the "other" (system) colors.
  ["@variable"] = { fg = c.fg },
  ["@variable.builtin"] = { fg = c.keyword, bold = true },
  ["@variable.parameter"] = { fg = c.fg },
  ["@variable.parameter.builtin"] = { fg = c.keyword, bold = true },
  ["@variable.member"] = { fg = c.func },
  ["@property"] = { fg = c.func },
  ["@constant"] = { fg = c.func },
  ["@constant.builtin"] = { fg = c.keyword, bold = true },
  ["@constant.macro"] = { fg = c.preproc },
  ["@module"] = { fg = c.type },
  ["@module.builtin"] = { fg = c.lib_type },
  ["@label"] = { fg = c.fg },

  ["@string"] = { fg = c.string },
  ["@string.documentation"] = { fg = c.comment },
  ["@string.regexp"] = { fg = c.string },
  ["@string.escape"] = { fg = c.number },
  ["@string.special"] = { fg = c.number },
  ["@string.special.url"] = { fg = c.url, underline = true },
  ["@character"] = { fg = c.number },
  ["@character.special"] = { fg = c.number },
  ["@boolean"] = { fg = c.keyword, bold = true },
  ["@number"] = { fg = c.number },
  ["@number.float"] = { fg = c.number },

  ["@type"] = { fg = c.type },
  ["@type.builtin"] = { fg = c.lib_type },
  ["@type.definition"] = { fg = c.type_decl },
  ["@attribute"] = { fg = c.attribute },
  ["@attribute.builtin"] = { fg = c.attribute },

  ["@function"] = { fg = c.other_decl },
  ["@function.builtin"] = { fg = c.lib_func },
  ["@function.call"] = { fg = c.func },
  ["@function.macro"] = { fg = c.preproc },
  ["@function.method"] = { fg = c.other_decl },
  ["@function.method.call"] = { fg = c.func },
  ["@constructor"] = { fg = c.type },

  ["@operator"] = { fg = c.fg },
  ["@punctuation"] = { fg = c.fg },
  ["@punctuation.special"] = { fg = c.fg },

  ["@keyword"] = { fg = c.keyword, bold = true },
  ["@keyword.directive"] = { fg = c.preproc },

  ["@comment"] = { fg = c.comment },
  ["@comment.documentation"] = { fg = c.comment },
  ["@comment.error"] = { fg = c.red, bold = true },
  ["@comment.warning"] = { fg = c.yellow, bold = true },
  ["@comment.todo"] = { fg = c.accent, bold = true },
  ["@comment.note"] = { fg = c.accent, bold = true },

  ["@markup"] = { fg = c.fg },
  ["@markup.heading"] = { fg = c.fg, bold = true },
  ["@markup.heading.4"] = { fg = c.secondary, bold = true },
  ["@markup.heading.5"] = { fg = c.secondary, bold = true },
  ["@markup.heading.6"] = { fg = c.secondary, bold = true },
  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { underline = true },
  ["@markup.quote"] = { fg = c.secondary, italic = true },
  ["@markup.math"] = { fg = c.number },
  ["@markup.link"] = { fg = c.url },
  ["@markup.link.url"] = { fg = c.url, underline = true },
  ["@markup.raw"] = { fg = c.string },
  ["@markup.raw.block"] = { fg = c.fg },
  ["@markup.list"] = { fg = c.secondary },
  ["@markup.list.checked"] = { fg = c.green },
  ["@markup.list.unchecked"] = { fg = c.secondary },

  ["@tag"] = { fg = c.keyword },
  ["@tag.builtin"] = { fg = c.keyword },
  ["@tag.attribute"] = { fg = c.attribute },
  ["@tag.delimiter"] = { fg = c.secondary },

  ["@diff.plus"] = { fg = c.green },
  ["@diff.minus"] = { fg = c.red },
  ["@diff.delta"] = { fg = c.accent },

  -- LSP semantic tokens, refining treesitter where the server knows more.
  ["@lsp.mod.deprecated"] = { strikethrough = true },
  ["@lsp.typemod.function.declaration"] = { link = "@function" },
  ["@lsp.typemod.method.declaration"] = { link = "@function.method" },
  ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
  ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
  ["@lsp.typemod.class.declaration"] = { link = "@type.definition" },
  ["@lsp.typemod.struct.declaration"] = { link = "@type.definition" },
  ["@lsp.typemod.enum.declaration"] = { link = "@type.definition" },
  ["@lsp.typemod.interface.declaration"] = { link = "@type.definition" },
  ["@lsp.typemod.type.declaration"] = { link = "@type.definition" },
  ["@lsp.typemod.class.defaultLibrary"] = { link = "@type.builtin" },
  ["@lsp.typemod.struct.defaultLibrary"] = { link = "@type.builtin" },
  ["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },

  -- Pickers and explorer: file names in label color, folders by icon only.
  SnacksPickerPrompt = { fg = c.secondary },
  SnacksPickerInputSearch = { fg = c.fg },
  SnacksPickerMatch = { fg = c.accent, bold = true },
  SnacksPickerDirectory = { fg = c.fg },
  SnacksPickerDir = { fg = c.secondary },
  SnacksPickerPathHidden = { fg = c.secondary },
  SnacksPickerPathIgnored = { fg = c.tertiary },
  SnacksPickerTree = { fg = c.tertiary },
  SnacksPickerTotals = { fg = c.secondary },
  SnacksPickerRow = { fg = c.secondary },
  SnacksPickerCol = { fg = c.tertiary },
  SnacksPickerSelected = { fg = c.accent },
  SnacksPickerUnselected = { fg = c.tertiary },
  SnacksPickerSpinner = { fg = c.secondary },
  SnacksPickerGitStatusModified = { fg = c.orange },
  SnacksPickerGitStatusUntracked = { fg = c.secondary },

  -- Diff review: file statuses match the picker; filler hatching stays faint.
  CodeDiffFiller = { fg = c.tertiary },
  CodeDiffStatusModified = { fg = c.orange },
  CodeDiffStatusUntracked = { fg = c.secondary },

  -- Key hints
  WhichKey = { fg = c.fg, bold = true },
  WhichKeyGroup = { fg = c.accent },
  WhichKeyDesc = { fg = c.fg },
  WhichKeySeparator = { fg = c.tertiary },
  WhichKeyValue = { fg = c.secondary },

  -- File icons
  MiniIconsAzure = { fg = c.accent },
  MiniIconsBlue = { fg = c.blue },
  MiniIconsCyan = { fg = c.teal },
  MiniIconsGreen = { fg = c.green },
  MiniIconsGrey = { fg = c.secondary },
  MiniIconsOrange = { fg = c.orange },
  MiniIconsPurple = { fg = c.purple },
  MiniIconsRed = { fg = c.red },
  MiniIconsYellow = { fg = c.yellow },

  -- netrw
  netrwClassify = { fg = c.tertiary },
  netrwTreeBar = { fg = c.tertiary },
  netrwExe = { fg = c.green },
  netrwSymLink = { fg = c.purple },
}

for name, spec in pairs(groups) do
  vim.api.nvim_set_hl(0, name, spec)
end

for i, color in ipairs(c.ansi) do
  vim.g["terminal_color_" .. (i - 1)] = color
end
