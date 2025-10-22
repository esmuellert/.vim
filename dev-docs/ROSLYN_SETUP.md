# Roslyn.nvim C# LSP Configuration

This configuration adds modern C# language server support using the Roslyn LSP for your .NET development in Neovim.

## What was added

1. **New plugin file**: `lua/plugins/roslyn.lua` - Contains the roslyn.nvim configuration
2. **Mason registry update**: Added custom registry for installing Roslyn server
3. **Plugin enabled flag**: Added `roslyn = true` to `lua/config/plugins-enabled.lua`
4. **Plugin loading**: Added roslyn to the plugin modules in `lua/plugins/init.lua`

## Installation Steps

### 1. Install Roslyn Language Server via Mason

After restarting Neovim, install the Roslyn language server:

```vim
:Mason
```

Then search for and install `roslyn` (or `roslyn-unstable` for bleeding edge features).

**Alternatively**, you can install it directly:

```vim
:MasonInstall roslyn
```

### 2. Verify Installation

Check if roslyn LSP is working:

```vim
:LspInfo
```

When you open a `.cs` file, you should see `roslyn` in the active clients list.

## Features Enabled

The configuration enables the following features:

### Inlay Hints
- Implicit object creation hints
- Implicit variable type hints
- Lambda parameter type hints
- Indexer parameter hints
- Literal parameter hints
- All parameter hints with smart suppression

### Code Lens
- References code lens (shows where symbols are used)
- Tests code lens (shows test methods)

### Completion
- Regex completions
- Completions from unimported namespaces
- Name completion suggestions

### Background Analysis

- **dotnet_analyzer_diagnostics_scope**: `'openFiles'` - Only analyzes currently open files (matches VS default behavior)
- **dotnet_compiler_diagnostics_scope**: `'openFiles'` - Only shows compiler diagnostics for open files

> **Note**: Changed from `'fullSolution'` to `'openFiles'` to match Visual Studio's default behavior and reduce diagnostic noise. The repository uses a custom ruleset (`build/code-analysis.ruleset`) that configures specific analyzer rules. Most diagnostics are set to Info level, which won't show as prominent warnings in the editor.

If you want full solution analysis (more diagnostics but may be slower), you can change both to `'fullSolution'` in `lua/plugins/roslyn.lua`.

### Other Features
- Symbol search in reference assemblies
- Auto-organize imports on format

## Configuration

The roslyn configuration is in `lua/plugins/roslyn.lua`. Key settings:

- **filewatching**: `"auto"` - Automatic file watching
- **broad_search**: `true` - Searches for solutions in parent directories
- **lock_target**: `false` - Allows switching between multiple solutions

### Multiple Solutions

If your repository has multiple `.sln` files (like your WAC project), roslyn will try to guess which one to use. You can switch between them:

```vim
:Roslyn target
```

The currently selected solution is stored in `vim.g.roslyn_nvim_selected_solution`.

## Your Repository Structure

Your WAC repository has:
- Main solution: `wac.sln`
- Multiple C# projects in `src/Controllers/` and `sample/`
- Uses `Directory.Packages.props` for package management

Roslyn is configured with `broad_search = true` to handle this structure properly.

## Commands

- `:Roslyn start` - Start the Roslyn language server
- `:Roslyn stop` - Stop the Roslyn language server
- `:Roslyn restart` - Restart the language server
- `:Roslyn target` - Choose which solution to use (if multiple exist)

## Keybindings

Your existing LSP keybindings from lspsaga will work with Roslyn:

- `gd` - Goto Definition
- `gr` - Find References
- `gi` - Goto Implementation
- `K` - Hover Documentation
- `rn` - Rename Symbol
- `<leader>ac` - Code Action
- `<leader>fm` - Format Buffer

## Diagnostic Levels

The configuration is set to match Visual Studio's behavior:

- **Error and Warning**: Displayed prominently with underlines, signs, and virtual text
- **Info and Hint**: Available in diagnostics but not shown inline (matching VS behavior)

This matches your repository's `.editorconfig` and `build/code-analysis.ruleset` settings. Most analyzer rules in your WAC repo are set to `Info` or `None`, which means they won't show as prominent warnings.

### Viewing All Diagnostics

If you want to see all diagnostics including Info/Hint levels:
- Use `:lua vim.diagnostic.setqflist()` to see all in quickfix list
- Use `:Telescope diagnostics` to browse all diagnostics

### Changing Diagnostic Display

To show Info and Hint diagnostics inline, edit `lua/plugins/roslyn.lua` and change:

```lua
virtual_text = {
  severity = { min = vim.diagnostic.severity.INFO },  -- Changed from WARN
},
```

## Enabling/Disabling

To disable roslyn.nvim temporarily, edit `lua/config/plugins-enabled.lua`:

```lua
roslyn = false,
```

## Troubleshooting

### LSP not attaching
1. Check if dotnet is installed: `dotnet --version`
2. Check Mason installation: `:Mason`
3. Check LSP logs: `:LspLog`

### Multiple solutions confusion
Use `:Roslyn target` to explicitly select which solution to use.

### Performance issues
If you experience slow performance with large solutions, the analysis scope is already set to `'openFiles'` which matches Visual Studio's default behavior. This should perform well even with large solutions.

If you want more comprehensive analysis across your entire solution, you can change the scope in `lua/plugins/roslyn.lua`:

```lua
['csharp|background_analysis'] = {
  dotnet_analyzer_diagnostics_scope = 'fullSolution',  -- Change from 'openFiles'
  dotnet_compiler_diagnostics_scope = 'fullSolution',  -- Change from 'openFiles'
},
```

Note: Full solution analysis will show more diagnostics but may impact performance on large codebases.

## References

- [roslyn.nvim GitHub](https://github.com/seblyng/roslyn.nvim)
- [Mason Registry PR](https://github.com/mason-org/mason-registry/pull/6330)
- [Roslyn Language Server](https://github.com/dotnet/roslyn)
