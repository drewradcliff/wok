# wok

Neovim with thoughtful defaults

## Install

Requires macOS, [Homebrew](https://brew.sh), and a [Nerd Font](https://www.nerdfonts.com) in your terminal for icons.

```sh
brew install drewradcliff/tap/wok
```

This brings Neovim, [ripgrep](https://github.com/BurntSushi/ripgrep), and [fd](https://github.com/sharkdp/fd) with it. Plugins install the first time you run `wok`.

wok runs under `NVIM_APPNAME=wok`, so it never touches your existing `nvim` setup.

## Upgrade

```sh
brew upgrade wok
```

Plugins are pinned with each release and move to the new versions the next time you open wok.

## Languages

Errors, warnings, and types just work. The first time you open a file in a language, its server downloads in the background and attaches when it's ready. Servers live in `~/.local/share/wok/servers`, pinned to the versions wok ships with.

| Language | Server |
| --- | --- |
| TypeScript, JavaScript | vtsls, or TypeScript 7's own server in projects that use it |
| Python | basedpyright and ruff, using the project's `.venv` |
| JSON, HTML, CSS | VS Code's language servers |
| Lua | lua-language-server |
| Rust | rust-analyzer (needs Rust) |
| Go | gopls, built with your Go (needs Go) |
| Swift, C, C++ | SourceKit-LSP and clangd, from the Xcode Command Line Tools |

A server you installed yourself, in the project or on your `PATH`, takes precedence. `:checkhealth vim.lsp` shows which servers are running.

## Usage

```sh
wok .
```

Opening a folder shows the file explorer. `<leader>` is `Space`

| Key | Action |
| --- | --- |
| `Space Space` / `Cmd-P` | Find files |
| `Space /` | Search in project |
| `Space ,` | Switch buffer |
| `Space e` | Toggle file explorer |
| `Space f…` | Find: `f` files, `r` recent, `b` buffers, `g` git files, `c` config |
| `Space s…` | Search: `w` word, `b` buffer lines, `h` help, `k` keymaps, `c` commands, `d` diagnostics, `s` symbols, `u` undo, `r` resume |
| `Space g…` | Git: `d` review changes, `f` file history, `s` status, `l` log, `b` branches |
| `]c` / `[c` | Next / previous change |
| `Space g…` on a change | `p` preview, `a` stage, `r` revert, `B` blame line |

Changed lines show a bar in the gutter. `ih` selects the change under the cursor, e.g. `vih` or `dih`.

In the review workspace (`Space g d`): `Enter` opens a file's diff, `-` stages or unstages it, `S` / `U` stage or unstage everything, `X` discards, `t` toggles side-by-side and inline, `q` closes, `g?` all keys. The diff engine downloads the first time you open it.

Problems appear at the end of the line, and the line number turns red or yellow. The status bar counts errors and warnings in the current file; `Space s d` lists them all.

| Key | Action |
| --- | --- |
| `K` | Type and documentation |
| `gd` | Go to definition |
| `]d` / `[d` | Next / previous problem, with its full message |
| `gra` / `grn` | Quick fix / rename |
| `Space t h` | Toggle inline type hints |

In the explorer: `a` add, `r` rename, `d` delete (to trash), `c` copy, `m` move, `o` open with default app, `/` filter, `?` all keys.

## Your settings

Put your own settings in `~/.config/wok.lua`. It runs after wok's, and upgrades never touch it.

```lua
vim.opt.relativenumber = true
vim.keymap.set("n", "<leader>q", "<Cmd>quit<CR>", { desc = "Quit" })
```

## Uninstall

```sh
brew uninstall wok
rm -rf ~/.config/wok ~/.local/share/wok ~/.local/state/wok ~/.cache/wok
```

## Development

Run wok from a checkout by putting its `bin/wok` on your `PATH`; it links `~/.config/wok` to the checkout's `config/`:

```sh
ln -s "$PWD/bin/wok" ~/.local/bin/wok
```

To bump plugins, run `:lua vim.pack.update()` in wok and commit `config/nvim-pack-lock.json`.

To release, set the new version in `config/VERSION`, commit, then tag and push:

```sh
git tag -a v0.2.0 -m "wok 0.2.0" && git push origin main v0.2.0
```

The release workflow creates the GitHub release and points the [Homebrew formula](https://github.com/drewradcliff/homebrew-tap) at it.

