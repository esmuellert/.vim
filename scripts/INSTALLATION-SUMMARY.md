# Installation Scripts - Complete Summary

## ✅ What Was Created

Three platform-specific installation scripts that install **all required dependencies** for the Neovim plugins in this configuration, based on official plugin documentation.

### 📁 Files Created

1. **`install-deps-linux.sh`** - Debian/Ubuntu (apt)
2. **`install-deps-macos.sh`** - macOS (Homebrew)
3. **`install-deps-windows.ps1`** - Windows (winget)
4. **`README.md`** - Complete installation guide
5. **`WINDOWS-DEPENDENCIES.md`** - Windows-specific requirements explained

## 🔍 Research Methodology

Dependencies were researched by:
1. ✅ Examining all 42 installed plugins in `~/.local/share/nvim/lazy/`
2. ✅ Reading official documentation from GitHub repositories:
   - nvim-treesitter README + Windows Support Wiki
   - telescope-fzf-native README
   - telescope.nvim README
   - mason.nvim README and requirements
3. ✅ Verifying Windows-specific requirements from official wikis

## 📦 Dependencies Installed

### Core Build Tools
- **Linux**: build-essential, cmake, make, pkg-config
- **macOS**: Xcode CLT, cmake, make, pkg-config, gnu-tar
- **Windows**: LLVM/Clang (or MSVC/MinGW), CMake

### Version Control
- **All platforms**: git

### Search Tools (Telescope)
- **ripgrep (rg)** - REQUIRED for live_grep and grep_string
- **fd** - Recommended for faster find_files

### Language Runtimes (LSP Servers)
- **Node.js + npm** - For TypeScript, ESLint, and many LSP servers
- **Python 3 + pip** - For Python-based tools
- **Rust + cargo** - For Rust-based tools and rust-analyzer

### Archive/Download Utilities
- **Linux**: curl, wget, unzip, tar, gzip
- **macOS**: curl, wget, unzip, tar (BSD), gzip
- **Windows**: curl (built-in), tar (built-in Win10+), 7-Zip

### Platform-Specific
- **Windows only**: PowerShell 5.1+, C compiler (critical for treesitter)
- **macOS only**: Homebrew, Xcode Command Line Tools
- **Linux only**: apt package manager

### Optional but Recommended
- **tree-sitter CLI** - For parser development
- **lazygit** - Enhanced git workflows

## 🎯 Key Windows Differences

The Windows script was **completely rewritten** based on actual requirements:

### What Changed from Initial Version

**Initial (incorrect) assumptions:**
- ❌ Visual Studio Build Tools required
- ❌ GNU Make needed
- ❌ Standard Unix toolchain approach

**Actual Windows requirements (from official docs):**
- ✅ C Compiler options: LLVM/Clang (recommended), MSVC, or MinGW
- ✅ CMake (yes, but builds without Make)
- ✅ PowerShell 5.1+ (not bash)
- ✅ tar comes with Windows 10+
- ✅ curl comes with Windows 10+
- ✅ 7-Zip for mason (not just any archiver)

### Critical Windows-Specific Points

1. **nvim-treesitter REQUIRES a C compiler** - This is non-optional
2. **LLVM/Clang recommended** - Works immediately without special shells
3. **MSVC works but requires Developer PowerShell** - Or manual PATH setup
4. **telescope-fzf-native uses CMake** - No make needed on Windows
5. **mason.nvim requires PowerShell** - Not cmd.exe

## 📊 Script Features

All scripts include:
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Smart detection** - Only installs missing packages
- ✅ **Color-coded output** - Green (✓), yellow (→), red (✗)
- ✅ **Detailed instructions** - Platform-specific next steps
- ✅ **Error handling** - Continues on errors, reports issues
- ✅ **PATH management** - Automatic PATH updates where needed

### Windows Script Special Features
- Compiler detection (clang/cl/gcc)
- Automatic LLVM installation if no compiler
- PATH configuration for LLVM
- MSVC-specific instructions
- PowerShell version check
- Built-in tool detection (curl, tar)

## 🚀 Usage

### Linux (Debian/Ubuntu)
```bash
chmod +x scripts/install-deps-linux.sh
./scripts/install-deps-linux.sh
```

### macOS
```bash
chmod +x scripts/install-deps-macos.sh
./scripts/install-deps-macos.sh
```

### Windows (PowerShell as Admin)
```powershell
.\scripts\install-deps-windows.ps1
```

## ✅ Verification

After running the script:
1. Restart your terminal
2. Open Neovim
3. Run `:checkhealth`
4. Run `:checkhealth telescope`
5. Run `:checkhealth nvim-treesitter`
6. Run `:checkhealth mason`

## 📚 Documentation

Complete documentation provided in:
- **README.md** - Installation instructions for all platforms
- **WINDOWS-DEPENDENCIES.md** - Windows-specific requirements explained
- **Inline script comments** - What each dependency is for

## 🎉 Result

Users can now:
- Run a single script to install ALL dependencies
- Understand what each dependency does
- Get platform-specific guidance
- Troubleshoot issues with clear error messages
- Switch between platforms easily

All based on **official plugin documentation** from the actual GitHub repositories! 🚀
