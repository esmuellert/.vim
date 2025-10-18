#!/usr/bin/env bash
#
# Neovim Plugin Dependencies Installer for Linux (Debian/Ubuntu)
# This script installs all required dependencies for nvim-treesitter, telescope,
# mason, and other plugins used in this Neovim configuration.
#
# Usage: ./install-deps-linux.sh
#

set -e  # Exit on error

echo "========================================="
echo "Neovim Plugin Dependencies Installer"
echo "Platform: Linux (Debian/Ubuntu with apt)"
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

# Function to install package if not already installed
install_if_missing() {
    local package=$1
    local check_command=${2:-$1}
    
    if command_exists "$check_command"; then
        echo -e "${GREEN}✓${NC} $package is already installed"
    else
        echo -e "${YELLOW}→${NC} Installing $package..."
        sudo apt-get install -y "$package"
        if command_exists "$check_command"; then
            echo -e "${GREEN}✓${NC} $package installed successfully"
        else
            echo -e "${RED}✗${NC} Failed to install $package"
            return 1
        fi
    fi
}

# Update package list
echo "Updating package lists..."
sudo apt-get update -qq

echo ""
echo "=== Core Build Tools ==="
echo ""

# Essential build tools
install_if_missing "build-essential" "gcc"
install_if_missing "make" "make"
install_if_missing "cmake" "cmake"
install_if_missing "pkg-config" "pkg-config"

echo ""
echo "=== Version Control ==="
echo ""

# Git
install_if_missing "git" "git"

echo ""
echo "=== Download Tools ==="
echo ""

# Download utilities
install_if_missing "curl" "curl"
install_if_missing "wget" "wget"

echo ""
echo "=== Archive Tools ==="
echo ""

# Archive extraction tools
install_if_missing "unzip" "unzip"
install_if_missing "tar" "tar"
install_if_missing "gzip" "gzip"

echo ""
echo "=== Search Tools (for Telescope) ==="
echo ""

# Ripgrep - required for telescope live_grep
install_if_missing "ripgrep" "rg"

# fd-find - better file finder (optional but recommended)
if ! command_exists "fd"; then
    echo -e "${YELLOW}→${NC} Installing fd-find..."
    sudo apt-get install -y fd-find
    # Create symlink if it doesn't exist
    if [ ! -e "$HOME/.local/bin/fd" ]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind 2>/dev/null || echo '/usr/bin/fdfind')" "$HOME/.local/bin/fd"
        echo -e "${GREEN}✓${NC} fd-find installed and linked to fd"
    else
        echo -e "${GREEN}✓${NC} fd-find is already installed"
    fi
else
    echo -e "${GREEN}✓${NC} fd is already installed"
fi

echo ""
echo "=== Language Runtimes (for LSP servers) ==="
echo ""

# Node.js and npm
if ! command_exists "node"; then
    echo -e "${YELLOW}→${NC} Installing Node.js and npm..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo -e "${GREEN}✓${NC} Node.js and npm installed"
else
    echo -e "${GREEN}✓${NC} Node.js is already installed ($(node --version))"
    echo -e "${GREEN}✓${NC} npm is already installed ($(npm --version))"
fi

# Python and pip
install_if_missing "python3" "python3"
install_if_missing "python3-pip" "pip3"
install_if_missing "python3-venv" "python3"

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
    echo -e "${YELLOW}→${NC} Installing tree-sitter CLI via npm..."
    sudo npm install -g tree-sitter-cli 2>/dev/null || npm install -g tree-sitter-cli --prefix="$HOME/.local"
    if command_exists "tree-sitter"; then
        echo -e "${GREEN}✓${NC} tree-sitter CLI installed"
    fi
else
    echo -e "${GREEN}✓${NC} tree-sitter CLI is already installed"
fi

# Lazygit (optional but very useful)
if ! command_exists "lazygit"; then
    echo -e "${YELLOW}→${NC} Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp
    sudo install /tmp/lazygit /usr/local/bin
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
    echo -e "${GREEN}✓${NC} lazygit installed"
else
    echo -e "${GREEN}✓${NC} lazygit is already installed"
fi

echo ""
echo "========================================="
echo "Installation Complete! ✨"
echo "========================================="
echo ""
echo "Summary of installed tools:"
echo "  • Build tools: gcc, make, cmake"
echo "  • VCS: git"
echo "  • Search: ripgrep (rg), fd"
echo "  • Languages: Node.js, Python, Rust"
echo "  • Utilities: curl, wget, unzip, tar, gzip"
echo "  • Optional: tree-sitter CLI, lazygit"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
echo "  2. Add ~/.local/bin to PATH if not already (for fd and other tools)"
echo "  3. Open Neovim and run: :checkhealth"
echo "  4. Install LSP servers with: :Mason"
echo ""
echo "Note: If you installed Rust/Cargo, run: source \$HOME/.cargo/env"
echo ""
