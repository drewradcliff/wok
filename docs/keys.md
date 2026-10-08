# Keys

`Space` is the leader key. Press it and wait to see what's available; `g?` shows the keys for the view you're in.

## Files and search

| Key | Action |
| --- | --- |
| `Space Space` / `Cmd-P` | Find files |
| `Space /` | Search in project |
| `Space ,` | Switch buffer |
| `Space e` | Toggle file explorer |
| `Space f f` | Files |
| `Space f r` | Recent files |
| `Space f b` | Buffers |
| `Space f g` | Git files |
| `Space f c` | wok's config files |
| `Space s w` | Search for the word under the cursor, or the selection |
| `Space s b` | Lines in the current buffer |
| `Space s h` | Help |
| `Space s k` | Keymaps |
| `Space s c` | Commands |
| `Space s u` | Undo history |
| `Space s r` | Resume the last search |

## In a picker

| Key | Action |
| --- | --- |
| `Enter` | Open |
| `Esc` | Close |
| `Ctrl-v` / `Ctrl-s` | Open in a vertical / horizontal split |
| `Ctrl-t` | Open in a new tab |
| `Tab` | Select several, then `Enter` to open them all |
| `Ctrl-q` | Send results to the quickfix list |
| `Alt-h` / `Alt-i` | Show hidden / ignored files |

## Editing

| Key | Action |
| --- | --- |
| `Cmd-S` / `Ctrl-S` | Save |
| `Option-Backspace` / `Ctrl-Backspace` | Delete the previous word (insert mode and command line) |
| `Cmd-Backspace` | Delete to the start of the line (insert mode and command line) |
| `Tab` / `Enter` | Accept the highlighted suggestion |
| `Ctrl-n` / `Ctrl-p` or `Down` / `Up` | Highlight the next / previous suggestion |
| `Ctrl-e` | Dismiss suggestions |
| `gcc` / `gc` | Comment line / selection |
| `<` / `>` | Indent selection (stays selected) |
| `Esc` | Clear search highlight |

## Windows

| Key | Action |
| --- | --- |
| `Ctrl-h` `Ctrl-j` `Ctrl-k` `Ctrl-l` | Move to the window left / below / above / right |
| `q` | Close help, quickfix, and other transient windows |
| `Esc Esc` | Leave terminal mode |

## Code and problems

| Key | Action |
| --- | --- |
| `K` | Type and documentation |
| `gd` | Go to definition |
| `grr` | References |
| `gri` | Implementations |
| `grt` | Type definitions |
| `gO` | Symbols in this file |
| `Space s s` | Symbols in the workspace |
| `gra` | Quick fix and other code actions |
| `grn` | Rename |
| `]d` / `[d` | Next / previous problem, with its full message |
| `Space s d` | All problems |
| `Space t h` | Toggle inline type hints |

## Git

In a file, changed lines show a bar in the gutter.

| Key | Action |
| --- | --- |
| `]c` / `[c` | Next / previous change |
| `Space g p` | Preview the change |
| `Space g a` | Stage the change (or the selected lines) |
| `Space g r` | Revert the change (or the selected lines) |
| `Space g B` | Blame the line |
| `ih` | The change as a text object, e.g. `vih` or `dih` |
| `Space g d` | Review all changes |
| `Space g f` | History of this file |
| `Space g s` | Status |
| `Space g l` | Log |
| `Space g b` | Branches |

### Review workspace

Opened with `Space g d`. The diff engine downloads the first time you open it.

| Key | Action |
| --- | --- |
| `Enter` | Open a file's diff |
| `-` | Stage or unstage the file |
| `S` / `U` | Stage / unstage everything |
| `X` | Discard the file's changes |
| `]f` / `[f` | Next / previous file |
| `]c` / `[c` | Next / previous change |
| `t` | Toggle side-by-side and inline |
| `q` | Close |
| `g?` | All keys |

## File explorer

Opened with `Space e`.

| Key | Action |
| --- | --- |
| `Enter` / `l` | Open file or folder |
| `h` | Close folder |
| `Backspace` | Go up a folder |
| `a` | Add a file, or a folder if the name ends in `/` |
| `r` | Rename |
| `d` | Delete (to the Trash) |
| `c` / `m` | Copy / move |
| `y` / `p` | Yank / paste files |
| `o` | Open with the default app |
| `/` | Filter |
| `H` / `I` | Show hidden / ignored files |
| `]g` / `[g` | Next / previous changed file |
| `]d` / `[d` | Next / previous file with problems |
| `?` | All keys |
