# Neovim Configuration

A well-organized, modular Neovim configuration following modern best practices.

## 📁 Directory Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point
├── vimrc                       # Legacy vim config (only for vim, not nvim)
├── lazy-lock.json              # Plugin version lock file
├── show-structure.sh           # Script to display config structure
├── .tmux.conf                  # Tmux configuration
├── lua/
│   ├── core/                   # Core Neovim settings
│   │   ├── init.lua           # Loads all core modules
│   │   ├── options.lua        # Vim options (spell, signcolumn, diagnostics)
│   │   ├── keymaps.lua        # Custom keybindings
│   │   ├── autocmds.lua       # Autocommands
│   │   ├── utils.lua          # Utility functions
│   │   └── file_reload.lua    # File reload utilities
│   ├── plugins/                # Plugin configurations
│   │   ├── init.lua           # Main plugin loader
│   │   ├── colorscheme.lua    # Lush theme & colorizer
│   │   ├── treesitter.lua     # Treesitter
│   │   ├── git.lua            # Gitsigns & Diffview
│   │   ├── telescope.lua      # Fuzzy finder
│   │   ├── editor.lua         # Comment, autopairs, illuminate, guess-indent
│   │   ├── ui.lua             # Lualine, bufferline, indent-blankline
│   │   ├── completion.lua     # nvim-cmp
│   │   ├── lsp.lua            # Mason, lspconfig, lspsaga, fidget
│   │   ├── diagnostics.lua    # Trouble
│   │   ├── filetree.lua       # nvim-tree
│   │   ├── which-key.lua      # Which-key
│   │   ├── eslint.lua         # ESLint integration
│   │   ├── xcodebuild.lua     # Xcodebuild (optional)
│   │   ├── writing.lua        # Writing plugins
│   │   ├── session.lua        # Session management
│   │   ├── roslyn.lua         # Roslyn LSP for C#
│   │   └── local-dev.lua      # Local development plugins
│   ├── themes/                 # Custom themes
│   │   └── github_light.lua   # Custom lush theme
│   ├── config/                 # Additional configs
│   │   ├── writing.lua        # Writing-specific config
│   │   ├── theme.lua          # Theme configuration
│   │   └── plugins-enabled.lua # Plugin enable/disable flags
│   └── local.lua              # Machine-specific settings (optional, gitignored)
├── colors/                     # Color scheme files
│   └── github_light.lua       # Theme entrypoint
├── after/                      # After directory for late-loading configs
│   └── plugin/                # Plugin-specific overrides
├── deprecated/                 # Old configuration backups
│   ├── init.lua.backup        # Backup of old config
│   └── nvim.deprecated.lua    # Old nvim.lua (not used)
├── scripts/                    # Installation and setup scripts
│   ├── README.md              # Scripts documentation
│   ├── INSTALLATION-SUMMARY.md
│   ├── WINDOWS-DEPENDENCIES.md
│   ├── install-deps-linux.sh
│   ├── install-deps-macos.sh
│   └── install-deps-windows.ps1
├── dev-docs/                   # Development documentation
└── tmp/                        # Temporary files
```

## 🚀 Quick Start

### Installation

1. Backup your existing config:
   ```bash
   mv ~/.config/nvim ~/.config/nvim.old
   ```

2. Clone or copy this configuration to `~/.config/nvim`

3. Start Neovim:
   ```bash
   nvim
   ```

4. Lazy.nvim will automatically install all plugins on first launch

### First-time Setup

Run `:checkhealth` to ensure everything is working properly.

## 🎨 Changing Color Themes

The configuration uses a custom GitHub Light theme built with lush.nvim.

### To switch to a different theme:

1. Open `lua/plugins/colorscheme.lua`
2. Comment out the custom github_light plugin (lines ~18-28)
3. Uncomment one of the example themes at the bottom of the file, or add your own
4. Restart Neovim

Example:
```lua
-- Comment out the custom theme
-- {
--   dir = vim.fn.stdpath("config") .. "/lua/themes/github_light.lua",
--   ...
-- },

-- Add a new theme
{
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd('colorscheme tokyonight')
  end,
},
```

## 🔌 Managing Plugins

### Adding a New Plugin

**Option 1: Add to existing category**
Edit the appropriate file in `lua/plugins/` and add your plugin spec:

```lua
-- In lua/plugins/editor.lua
{
  'username/plugin-name',
  event = 'BufRead',  -- lazy load on buffer read
  config = function()
    require('plugin-name').setup({})
  end,
}
```

**Option 2: Create a new category**
Create a new file like `lua/plugins/myfeature.lua`:

```lua
return {
  {
    'username/plugin-name',
    config = function()
      -- configuration here
    end,
  },
}
```

Then add it to `lua/plugins/init.lua`:
```lua
local plugin_modules = {
  -- ... existing modules ...
  require("plugins.myfeature"),
}
```

### Disabling a Plugin

**Temporary disable:**
Add `enabled = false` to the plugin spec:
```lua
{
  'username/plugin-name',
  enabled = false,
  -- ... rest of config
}
```

**Permanent removal:**
Comment out or delete the plugin spec from its file.

### Updating Plugins

- `:Lazy sync` - Update all plugins
- `:Lazy update` - Update plugins only
- `:Lazy clean` - Remove unused plugins

## ⚙️ Customization

### Adding Custom Keymaps

Edit `lua/core/keymaps.lua`:

```lua
vim.keymap.set('n', '<leader>xx', ':MyCommand<CR>', { desc = 'My custom command' })
```

### Adding Custom Options

Edit `lua/core/options.lua`:

```lua
vim.opt.number = true
vim.opt.relativenumber = true
```

### Adding Custom Autocommands

Edit `lua/core/autocmds.lua`:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
  end,
})
```

### Machine-Specific Settings

Create `lua/local.lua` for settings that shouldn't be version controlled:

```lua
-- lua/local.lua
vim.g.python3_host_prog = '/usr/local/bin/python3'
-- Add any machine-specific settings here
```

This file is automatically loaded if it exists.

## 🔧 Configuration Files

### Plugin Management
- `lua/config/plugins-enabled.lua` - Central file to enable/disable plugin categories
- `lua/plugins/local-dev.lua` - Local development-specific plugins

### Additional Features
- Session management via `lua/plugins/session.lua`
- Roslyn LSP support for C# development via `lua/plugins/roslyn.lua`
- File reload utilities in `lua/core/file_reload.lua`

### Installation Scripts
The `scripts/` directory contains platform-specific installation scripts:
- `install-deps-linux.sh` - Linux dependency installation
- `install-deps-macos.sh` - macOS dependency installation  
- `install-deps-windows.ps1` - Windows dependency installation
- See `scripts/README.md` for detailed documentation

## 📝 Key Bindings

### General
- `<leader>` is `<Space>`
- `<leader>t` - Toggle terminal
- `<leader>g` - Toggle LazyGit
- `<A-S-F>` - Format with Prettier

### File Navigation
- `<leader>p` - Find files
- `<leader>f` - Live grep
- `<leader>b` - List buffers
- `<leader>E` - Toggle file tree

### Git
- `<leader>df` - Toggle diff view
- `]c` / `[c` - Next/previous git hunk
- `<leader>hk` - Preview hunk

### LSP
- `gd` - Go to definition
- `gr` - Find references
- `gi` - Go to implementation
- `K` - Hover documentation
- `rn` - Rename symbol
- `<leader>ac` - Code actions
- `<leader>fm` - Format buffer

### Diagnostics
- `<leader>tb` - Toggle trouble (diagnostics list)
- `<leader>d` - Telescope diagnostics

## 🔄 Migration from Old Config

The old configuration is backed up in the `deprecated/` directory:
- `deprecated/init.lua.backup` - Backup of old init.lua
- `deprecated/nvim.deprecated.lua` - Old nvim.lua (not used)

All functionality from the old config has been preserved in the new structure.

## 📚 Resources

- [Lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [LazyVim](https://www.lazyvim.org/) - Reference for best practices
- [Neovim Documentation](https://neovim.io/doc/)
