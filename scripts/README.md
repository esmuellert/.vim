# Installation Scripts

This directory contains platform-specific installation scripts for all dependencies required by the Neovim plugins in this configuration.

## 📦 What Gets Installed

These scripts install all necessary dependencies for:

- **nvim-treesitter** - C compiler, make, tree-sitter parsers
- **telescope.nvim** - ripgrep, fd, CMake (for fzf-native)
- **telescope-fzf-native** - CMake, C compiler
- **mason.nvim** - git, curl/wget, unzip, tar, gzip, Node.js, Python, Rust
- **LSP servers** - Language runtimes (Node.js, Python, Rust, etc.)
- **Other plugins** - Various utilities

## 🖥️ Platform Scripts

### Linux (Debian/Ubuntu)
```bash
chmod +x scripts/install-deps-linux.sh
./scripts/install-deps-linux.sh
```

**Installs:**
- Build tools: `build-essential`, `make`, `cmake`, `pkg-config`
- Version control: `git`
- Download tools: `curl`, `wget`
- Archive tools: `unzip`, `tar`, `gzip`
- Search tools: `ripgrep` (rg), `fd-find`
- Language runtimes: Node.js (LTS), Python 3, Rust/Cargo
- Optional: `tree-sitter` CLI, `lazygit`

### macOS (Homebrew)
```bash
chmod +x scripts/install-deps-macos.sh
./scripts/install-deps-macos.sh
```

**Installs:**
- Xcode Command Line Tools (if not present)
- Build tools: `cmake`, `make`, `pkg-config`, `gnu-tar`
- Version control: `git`
- Download tools: `wget` (curl included in macOS)
- Search tools: `ripgrep`, `fd`
- Language runtimes: Node.js (LTS), Python 3, Rust/Cargo
- Optional: `tree-sitter` CLI, `lazygit`

### Windows (winget)
```powershell
# Run PowerShell as Administrator
.\scripts\install-deps-windows.ps1
```

**Installs:**
- Build tools: Visual Studio Build Tools (MSVC), CMake, GNU Make
- Version control: Git
- Download tools: `wget` (curl included in Windows 10+)
- Archive tools: 7-Zip, GNU tar
- Search tools: `ripgrep`, `fd`
- Language runtimes: Node.js (LTS), Python 3, Rust/Cargo
- Optional: `tree-sitter` CLI, `lazygit`

## ✅ Verification

After running the appropriate script for your platform:

1. **Restart your terminal** to refresh PATH
2. Open Neovim and run: `:checkhealth`
3. Check telescope: `:checkhealth telescope`
4. Check treesitter: `:checkhealth nvim-treesitter`
5. Check mason: `:checkhealth mason`

## 🔧 Manual LSP Server Installation

After dependencies are installed, you can install LSP servers:

```vim
:Mason
```

Or install specific servers:
```vim
:MasonInstall ts_ls lua_ls
```

## 📋 Dependency Checklist

### Core Build Tools
- [x] C compiler (gcc/clang/msvc)
- [x] make
- [x] cmake
- [x] pkg-config

### Version Control
- [x] git

### Search & Find (Telescope)
- [x] ripgrep (rg) - **Required** for `live_grep` and `grep_string`
- [x] fd - Recommended for faster `find_files`

### Language Runtimes
- [x] Node.js & npm - For many LSP servers
- [x] Python 3 & pip - For Python-based tools
- [x] Rust & cargo - For Rust-based tools and servers

### Archive Utilities
- [x] curl or wget
- [x] unzip
- [x] tar
- [x] gzip

### Optional but Recommended
- [x] tree-sitter CLI - For parser development
- [x] lazygit - Better git interface

## 🐛 Troubleshooting

### Command not found after installation

**Linux/macOS:**
```bash
# Refresh your shell
source ~/.bashrc  # or ~/.zshrc
# Or restart your terminal

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

**Windows:**
- Restart your terminal/PowerShell
- Or log out and log back in

### CMake build errors

Make sure you have:
- A C compiler installed
- CMake 3.x or higher
- Build tools for your platform

### Mason installation failures

1. Check internet connection
2. Verify git is installed: `git --version`
3. Check `:checkhealth mason` for specific issues
4. Try manual installation: `:MasonInstall <server-name>`

### Telescope live_grep not working

- Ensure `ripgrep` is installed: `rg --version`
- Check if `rg` is in PATH
- Run `:checkhealth telescope`

## 📚 Additional Resources

- [nvim-treesitter requirements](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
- [telescope.nvim dependencies](https://github.com/nvim-telescope/telescope.nvim#suggested-dependencies)
- [mason.nvim requirements](https://github.com/williamboman/mason.nvim#requirements)
- [telescope-fzf-native build](https://github.com/nvim-telescope/telescope-fzf-native.nvim#installation)

## 🤝 Contributing

If you find issues with these scripts or want to add support for other package managers (pacman, dnf, etc.), please submit a pull request!

## 📝 Notes

- Scripts check if tools are already installed before attempting installation
- Color-coded output: ✓ (green) = installed, → (yellow) = installing, ✗ (red) = error
- All scripts are idempotent - safe to run multiple times
- Scripts will skip already-installed packages
