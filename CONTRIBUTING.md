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
