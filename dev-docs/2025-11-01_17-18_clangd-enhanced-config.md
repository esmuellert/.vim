# Enhanced Clangd Configuration for Neovim 0.12 & Clangd-21

**Timestamp:** 2025-11-01 17:18  
**Status:** Implemented

## Overview

This configuration optimizes clangd with enhanced command-line arguments and automatic clangd-21+ feature detection.

## Key Features

### 1. **Version Detection**
- Automatically detects clangd version
- Enables clangd-21+ specific features when available

### 2. **Enhanced Command-Line Arguments**

#### Core Arguments (all versions):
- `--background-index`: Fast background indexing for large projects
- `--clang-tidy`: Integrated static analysis
- `--header-insertion=iwyu`: Smart header insertion (Include What You Use)
- `--completion-style=detailed`: Detailed completion items
- `--function-arg-placeholders`: Placeholder text for function arguments
- `--fallback-style=llvm`: LLVM coding style as fallback
- `--pch-storage=memory`: Store precompiled headers in memory for speed
- `--all-scopes-completion`: Suggest symbols from all scopes
- `--completion-parse=auto`: Auto-select completion parsing strategy
- `--enable-config`: Enable `.clangd` config file support
- `--offset-encoding=utf-16`: UTF-16 offset encoding for better compatibility

#### Clangd-21+ Specific:
- `--header-insertion-decorators`: Visual indicators for header insertions
- `--ranking-model=decision_forest`: ML-based completion ranking
- `--limit-results=0`: No artificial limit on results (let editor handle)

### 3. **Enhanced Capabilities**
- UTF-16 offset encoding for better multi-byte character support
- `editsNearCursor` enabled for better completion performance
- Full inlay hints support

### 4. **Custom Key Mappings**
- `<leader>ch`: Switch between source/header files
- `<leader>ci`: Display symbol info under cursor
- `<leader>ct`: Show type hierarchy

### 5. **Protocol Extensions**
- Custom handler for `textDocument/clangd.fileStatus`
- Support for clangd-specific LSP extensions

## Configuration Details

### Init Options
```lua
init_options = {
  usePlaceholders = true,          -- Use placeholders in completions
  completeUnimported = true,       -- Auto-suggest unimported symbols
  clangdFileStatus = true,         -- Enable file status notifications
  compilationDatabasePath = '',    -- Auto-detect compile_commands.json
  fallbackFlags = {},              -- Project-specific flags if needed
}
```

### Custom Handlers
- Handles clangd's file status updates gracefully
- Returns `vim.NIL` to prevent unnecessary processing

## Project Setup Recommendations

### 1. **Compilation Database**
Create `compile_commands.json` in your project root:

```bash
# For CMake projects:
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .

# For Make projects:
bear -- make

# For other build systems:
# Use compiledb or similar tools
```

### 2. **`.clangd` Configuration File**
Create `.clangd` in project root for project-specific settings:

```yaml
CompileFlags:
  Add: [-std=c++23, -Wall, -Wextra]
  Remove: [-W*]
  Compiler: clang++

Diagnostics:
  UnusedIncludes: Strict
  MissingIncludes: Strict
  ClangTidy:
    Add: [performance-*, modernize-*, bugprone-*]
    Remove: [modernize-use-trailing-return-type]
    CheckOptions:
      readability-identifier-naming.VariableCase: camelBack

Index:
  Background: Build
  StandardLibrary: Yes

InlayHints:
  Enabled: Yes
  ParameterNames: Yes
  DeducedTypes: Yes
  Designators: Yes
```

### 3. **User-Level Configuration**
Create `~/.config/clangd/config.yaml` for global settings:

```yaml
CompileFlags:
  CompilationDatabase: .

Diagnostics:
  Suppress: ['pp_including_mainfile_in_preamble']

Hover:
  ShowAKA: Yes
```

## Best Practices

1. **Keep compilation database updated**: Regenerate after build system changes
2. **Use project-specific `.clangd` files**: Tailor settings per project
3. **Enable clang-tidy checks**: Leverage static analysis for code quality
4. **Configure inlay hints**: Set preferences in `.clangd` config
5. **Monitor memory usage**: Large projects may need `--pch-storage=disk`

## Troubleshooting

### Slow Performance
- Reduce clang-tidy checks in `.clangd`
- Use `--pch-storage=disk` instead of memory
- Add `--limit-results=50` if too many results

### Missing Symbols
- Verify `compile_commands.json` is up-to-date
- Check `CompilationDatabase` path in config
- Ensure all source files are in compilation database

### Incorrect Diagnostics
- Verify compiler flags in compilation database
- Check `.clangd` config for flag overrides
- Ensure correct C++ standard is set

## References

- [Clangd Documentation](https://clangd.llvm.org/)
- [Clangd Configuration](https://clangd.llvm.org/config)
- [Neovim LSP Documentation](https://neovim.io/doc/user/lsp.html)
- [Clangd Extensions Protocol](https://clangd.llvm.org/extensions)

## Future Improvements

- Consider adding `clangd_extensions.nvim` plugin for additional features:
  - AST viewer
  - Memory usage display
  - Enhanced completion sorting
  - Better symbol information display
