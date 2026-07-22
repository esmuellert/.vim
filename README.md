# Neovim Configuration

A minimal, modular Neovim config built on [lazy.nvim](https://github.com/folke/lazy.nvim).

Every file under `lua/plugins/` is a self-contained plugin spec, auto-imported by lazy.nvim:
**presence enables it, deleting the file removes it** — there is no central enable/disable list.

## Structure

```
~/.config/nvim/
├── init.lua                 # leader keys + require config modules
├── lua/
│   ├── config/
│   │   ├── options.lua      # vim options & diagnostics
│   │   ├── keymaps.lua      # global keymaps + :Diff command
│   │   ├── autocmds.lua     # autocmds (diagnostic HL, external file reload, config auto-update)
│   │   └── lazy.lua         # bootstraps lazy.nvim, imports lua/plugins/, sets colorscheme
│   ├── plugins/             # one plugin spec per file (auto-imported)
│   └── local.lua            # machine-specific settings (optional, gitignored)
├── lazy-lock.json           # plugin version lockfile
├── home.nix                 # Nix home-manager (installs tools/deps)
├── .tmux.conf               # tmux config
├── .stylua.toml/.luarc.json # Lua format & LSP hints
└── scripts/                 # cross-platform dependency installers
```

## Plugins

| Area          | Plugins                                                    |
| ------------- | ---------------------------------------------------------- |
| Finder        | fzf-lua                                                    |
| File manager  | yazi.nvim                                                  |
| Git           | gitsigns · vim-fugitive · diffview.nvim · codediff.nvim    |
| Treesitter    | nvim-treesitter                                            |
| Completion    | blink.cmp (buffer / path / snippets)                       |
| Formatting    | conform.nvim                                               |
| UI            | lualine · noice.nvim · snacks.nvim · which-key             |
| Editing       | nvim-autopairs · guess-indent · todo-comments             |
| Content       | render-markdown · kulala.nvim (HTTP client)                |
| Session       | persistence.nvim                                           |
| Colorscheme   | iceberg                                                    |

## Managing plugins

- **Add:** create `lua/plugins/<name>.lua` returning a lazy spec (or add to a related file).
- **Remove:** delete the file.
- **Sync / update / clean:** `:Lazy sync` · `:Lazy update` · `:Lazy clean` (or `<leader>L`).

## LSP

LSP is intentionally **not configured** in this minimal setup. It can be re-added later
using Neovim's native `vim.lsp.config` / `vim.lsp.enable` (0.11+) under a `lua/lsp/` folder.

## Key bindings

Leader is `<Space>`.

| Key                                | Action                                   |
| ---------------------------------- | ---------------------------------------- |
| `<leader>p` / `<leader>f` / `<leader>b` | Files / live grep / buffers (fzf-lua) |
| `<leader>r`                        | Recent files                             |
| `<leader>e` / `<leader>cw`         | Yazi at file / cwd                       |
| `<leader>g` / `<leader>t`          | LazyGit / terminal (snacks)              |
| `<leader>d` / `<leader>df`         | CodeDiff working tree (staged+unstaged)  |
| `<leader>d1` `d2` `d3` / `<leader>dm` | CodeDiff vs HEAD~N / vs main·master   |
| `<leader>db` / `<leader>dc` / `<leader>dr` | CodeDiff vs branch / commit / ref (pick) |
| `<leader>ds` / `<leader>dC`        | CodeDiff show commit / current-file commit (pick) |
| `<leader>dh`                       | CodeDiff history                         |
| `<leader>hk`                       | Preview git hunk                         |
| `<leader>fm`                       | Format buffer (conform)                  |
| `<leader>qs` / `<leader>ql`        | Restore session / last session           |
| `<leader>R…`                       | kulala HTTP client (in `.http` files)    |
| `:Diff [ref]`                      | Diff current file against a git ref      |

## Machine-specific settings

Create `lua/local.lua` (gitignored) for anything machine-specific; it is loaded automatically.

## Dependencies

External tools (ripgrep, fd, fzf, yazi, lazygit, prettierd, stylua, …) are provisioned via
`home.nix` on Nix systems, or the platform installers in `scripts/`.

## History

The previous full-featured config (LSP, Mason-era tooling, multiple themes, telescope, etc.)
is preserved on the `archive/legacy-lazy-config` branch and the `v1.0-legacy` tag.
