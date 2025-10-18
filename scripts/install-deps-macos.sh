#!/usr/bin/env bash
#
# Neovim Plugin Dependencies Installer for macOS
# This script installs all required dependencies for nvim-treesitter, telescope,
# mason, and other plugins used in this Neovim configuration.
#
# Usage: ./install-deps-macos.sh
#

set -e  # Exit on error

echo "========================================="
echo "Neovim Plugin Dependencies Installer"
echo "Platform: macOS (Homebrew)"
echo "========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Homebrew is installed
if ! command_exists "brew"; then
    echo -e "${YELLOW}→${NC} Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo -e "${GREEN}✓${NC} Homebrew installed"
else
    echo -e "${GREEN}✓${NC} Homebrew is already installed"
fi

# Function to install package if not already installed
install_if_missing() {
    local package=$1
    local check_command=${2:-$1}
    
    if command_exists "$check_command"; then
        echo -e "${GREEN}✓${NC} $package is already installed"
    else
        echo -e "${YELLOW}→${NC} Installing $package..."
        brew install "$package"
        if command_exists "$check_command"; then
            echo -e "${GREEN}✓${NC} $package installed successfully"
        else
            echo -e "${RED}✗${NC} Failed to install $package"
            return 1
        fi
    fi
}

# Update Homebrew
echo "Updating Homebrew..."
brew update

echo ""
echo "=== Core Build Tools ==="
echo ""

# CMake and build tools (most come with Xcode Command Line Tools)
if ! xcode-select -p &>/dev/null; then
    echo -e "${YELLOW}→${NC} Installing Xcode Command Line Tools..."
    xcode-select --install
    echo -e "${YELLOW}!${NC} Please complete the Xcode Command Line Tools installation and re-run this script"
    exit 1
else
    echo -e "${GREEN}✓${NC} Xcode Command Line Tools are installed"
fi

install_if_missing "cmake" "cmake"
install_if_missing "make" "make"
install_if_missing "pkg-config" "pkg-config"

# GNU tar (macOS tar is BSD tar, but GNU tar is needed for some operations)
if ! command_exists "gtar"; then
    echo -e "${YELLOW}→${NC} Installing GNU tar..."
    brew install gnu-tar
    echo -e "${GREEN}✓${NC} GNU tar installed"
else
    echo -e "${GREEN}✓${NC} GNU tar is already installed"
fi

echo ""
echo "=== Version Control ==="
echo ""

# Git (comes with Xcode CLT but Homebrew version is newer)
if ! command_exists "git"; then
    install_if_missing "git" "git"
else
    echo -e "${GREEN}✓${NC} git is already installed ($(git --version | cut -d' ' -f3))"
fi

echo ""
echo "=== Download Tools ==="
echo ""

# curl and wget (curl comes with macOS)
if ! command_exists "curl"; then
    install_if_missing "curl" "curl"
else
    echo -e "${GREEN}✓${NC} curl is already installed"
fi

install_if_missing "wget" "wget"

echo ""
echo "=== Archive Tools ==="
echo ""

# unzip, gzip (come with macOS)
if ! command_exists "unzip"; then
    echo -e "${YELLOW}!${NC} unzip should come with macOS. Something might be wrong."
else
    echo -e "${GREEN}✓${NC} unzip is already installed"
fi

if ! command_exists "gzip"; then
    echo -e "${YELLOW}!${NC} gzip should come with macOS. Something might be wrong."
else
    echo -e "${GREEN}✓${NC} gzip is already installed"
fi

echo ""
echo "=== Search Tools (for Telescope) ==="
echo ""

# Ripgrep - required for telescope live_grep
install_if_missing "ripgrep" "rg"

# fd - better file finder (optional but recommended)
install_if_missing "fd" "fd"

echo ""
echo "=== Language Runtimes (for LSP servers) ==="
echo ""

# Node.js and npm
install_if_missing "node" "node"

# Python (macOS comes with Python 3)
if ! command_exists "python3"; then
    install_if_missing "python@3" "python3"
else
    echo -e "${GREEN}✓${NC} Python 3 is already installed ($(python3 --version))"
fi

# Ensure pip is installed
if ! command_exists "pip3"; then
    echo -e "${YELLOW}→${NC} Installing pip..."
    python3 -m ensurepip --upgrade
    echo -e "${GREEN}✓${NC} pip installed"
else
    echo -e "${GREEN}✓${NC} pip is already installed"
fi

# Cargo/Rust (for some LSP servers and tools)
if ! command_exists "cargo"; then
    echo -e "${YELLOW}→${NC} Installing Rust and Cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Rust and Cargo installed"
else
    echo -e "${GREEN}✓${NC} Cargo is already installed ($(cargo --version))"
fi

echo ""
echo "=== Additional Development Tools ==="
echo ""

# Tree-sitter CLI (optional but useful for parser development)
if ! command_exists "tree-sitter"; then
    echo -e "${YELLOW}→${NC} Installing tree-sitter CLI..."
    brew install tree-sitter
    echo -e "${GREEN}✓${NC} tree-sitter CLI installed"
else
    echo -e "${GREEN}✓${NC} tree-sitter CLI is already installed"
fi

# Lazygit (optional but very useful)
install_if_missing "lazygit" "lazygit"

echo ""
echo "========================================="
echo "Installation Complete! ✨"
echo "========================================="
echo ""
echo "Summary of installed tools:"
echo "  • Build tools: clang (Xcode CLT), make, cmake"
echo "  • VCS: git"
echo "  • Search: ripgrep (rg), fd"
echo "  • Languages: Node.js, Python, Rust"
echo "  • Utilities: curl, wget, unzip, tar, gzip"
echo "  • Optional: tree-sitter CLI, lazygit"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
echo "  2. Open Neovim and run: :checkhealth"
echo "  3. Install LSP servers with: :Mason"
echo ""
echo "Note: If you installed Rust/Cargo, run: source \$HOME/.cargo/env"
echo ""
