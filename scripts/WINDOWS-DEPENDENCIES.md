# Windows-Specific Dependencies for Neovim Plugins

This document explains the **Windows-specific** dependencies required for the Neovim plugins in this configuration, based on official documentation from nvim-treesitter, telescope-fzf-native, and mason.nvim.

## 🔍 Research Sources

All dependencies were verified against official documentation:
- [nvim-treesitter Windows Support Wiki](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support)
- [telescope-fzf-native README](https://github.com/nvim-telescope/telescope-fzf-native.nvim#cmake-windows-linux-macos)
- [mason.nvim Requirements](https://github.com/williamboman/mason.nvim#requirements)

## ⚠️ Critical Windows-Specific Requirements

### 1. C Compiler (REQUIRED for nvim-treesitter)

**nvim-treesitter REQUIRES a C compiler** to compile tree-sitter parsers. You have three options:

#### Option 1: LLVM/Clang (✅ Recommended)
- **Why**: Easiest setup, works immediately after PATH refresh
- **Install**: `winget install LLVM.LLVM`
- **Advantage**: No special environment needed
- **Used by**: nvim-treesitter, telescope-fzf-native

#### Option 2: Visual Studio Build Tools (MSVC)
- **Why**: If you already have Visual Studio or need MSVC
- **Install**: Visual Studio Build Tools with C++ workload
- **Caveat**: Requires launching Neovim from Developer PowerShell/Command Prompt
- **Alternative**: Set environment variables (PATH, INCLUDE, LIB) - see [wiki](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#msvc)

#### Option 3: MinGW-w64 (GCC)
- **Why**: If you prefer GCC toolchain
- **Install**: `choco install mingw` or `winget install GnuWin32.MinGW`
- **Note**: Less commonly used on Windows

### 2. CMake (REQUIRED for telescope-fzf-native)

- **Install**: `winget install Kitware.CMake`
- **Why**: telescope-fzf-native is written in C and must be compiled with CMake
- **Note**: Works with any of the above compilers (Clang/MSVC/GCC)

### 3. PowerShell 5.1+ (REQUIRED for mason.nvim)

- **Built-in**: Windows 10/11 includes PowerShell 5.1
- **Check version**: Run `$PSVersionTable.PSVersion`
- **Optional upgrade**: PowerShell Core 7+ (`winget install Microsoft.PowerShell`)

### 4. Git (REQUIRED for mason and nvim-treesitter)

- **Install**: `winget install Git.Git`
- **Why**: Mason downloads packages, nvim-treesitter downloads parsers

### 5. GNU tar (REQUIRED for mason)

- **Built-in**: Windows 10+ includes BSD tar
- **Verify**: Run `tar --version`
- **If missing**: `winget install GnuWin32.Tar`

### 6. Archive Utility (REQUIRED for mason)

Mason requires ONE of these for extracting packages:
- **7-Zip** (Recommended): `winget install 7zip.7zip`
- peazip
- archiver  
- winzip
- WinRAR

### 7. curl or Invoke-WebRequest (for downloads)

- **Built-in**: Windows 10+ includes curl
- **Alternative**: PowerShell's `Invoke-WebRequest` (works automatically)

## 📦 Language Runtimes (for LSP Servers)

These are needed for various LSP servers installed via Mason:

- **Node.js**: `winget install OpenJS.NodeJS.LTS` (for typescript, eslint, etc.)
- **Python 3**: `winget install Python.Python.3.12` (for python tools)
- **Rust/Cargo**: `winget install Rustlang.Rust.MSVC` (for rust-analyzer)

## ⚡ Search Tools (for Telescope)

- **ripgrep** (REQUIRED): `winget install BurntSushi.ripgrep.MSVC`
  - Used by `:Telescope live_grep` and `:Telescope grep_string`
- **fd** (recommended): `winget install sharkdp.fd`
  - Faster alternative for `:Telescope find_files`

## 🔧 Windows-Specific Configuration

### For MSVC Users

If using Visual Studio Build Tools (MSVC), add to your `init.lua`:

```lua
require('nvim-treesitter.install').compilers = { 'cl', 'clang', 'gcc' }
```

And launch Neovim from:
- Developer PowerShell for VS 2022, OR
- Developer Command Prompt for VS 2022

### For telescope-fzf-native

The plugin is configured to build with CMake on Windows:
```lua
build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
```

## 📝 Summary: What's Different on Windows?

| Component | Linux/macOS | Windows | Why Different? |
|-----------|-------------|---------|----------------|
| **C Compiler** | gcc/clang (system) | LLVM/MSVC/MinGW (install required) | No system compiler on Windows |
| **Make** | GNU make (system) | Not required (CMake builds directly) | Windows uses different build system |
| **Archive tools** | tar/gzip (system) | tar (built-in Win10+), 7-Zip | Different archive ecosystem |
| **Shell** | bash/zsh | PowerShell 5.1+ | Windows uses PowerShell |
| **curl** | curl (system) | curl (Win10+) or Invoke-WebRequest | Both work on modern Windows |

## ✅ Installation Script

The `install-deps-windows.ps1` script handles all of this automatically:
- Detects existing compilers
- Installs LLVM/Clang if no compiler found
- Configures PATH automatically
- Provides clear next steps based on what's installed

## 🐛 Common Windows Issues

### `:TSInstall` fails with compiler error
- **Cause**: No C compiler in PATH
- **Fix**: Install LLVM or use Developer PowerShell with MSVC

### telescope-fzf-native build fails
- **Cause**: CMake or C compiler not found
- **Fix**: Install CMake and ensure compiler is in PATH

### Mason can't download packages
- **Cause**: Missing PowerShell, git, tar, or archiver
- **Fix**: Run `:checkhealth mason` to see what's missing

## 📚 Additional Resources

- [nvim-treesitter Windows Support](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support)
- [telescope-fzf-native Installation](https://github.com/nvim-telescope/telescope-fzf-native.nvim#installation)
- [mason.nvim Requirements](https://github.com/williamboman/mason.nvim#requirements)
