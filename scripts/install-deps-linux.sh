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

# Install ZSH first
echo "=== Installing ZSH and Oh My Zsh ==="
echo ""

# Download and run the ZSH installation script
ZSH_INSTALL_SCRIPT="/tmp/install_zsh.sh"
echo "Downloading ZSH installation script..."
curl -fsSL https://raw.githubusercontent.com/esmuellert/material-deep-ocean-zsh/main/install_zsh.sh -o "$ZSH_INSTALL_SCRIPT"
chmod +x "$ZSH_INSTALL_SCRIPT"

echo "Running ZSH installation..."
bash "$ZSH_INSTALL_SCRIPT"

# Clean up
rm -f "$ZSH_INSTALL_SCRIPT"

echo ""
echo "ZSH installation completed!"
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
echo "=== Terminal Multiplexer ==="
echo ""

# tmux
install_if_missing "tmux" "tmux"

# Install tmux configuration
if command_exists "tmux"; then
    echo -e "${YELLOW}→${NC} Setting up tmux configuration..."
    
    # Backup existing tmux.conf if it exists
    if [ -f "$HOME/.tmux.conf" ]; then
        echo "Backing up existing .tmux.conf..."
        cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copy tmux config from nvim config directory
    NVIM_TMUX_CONF="$HOME/.config/nvim/.tmux.conf"
    if [ -f "$NVIM_TMUX_CONF" ]; then
        cp "$NVIM_TMUX_CONF" "$HOME/.tmux.conf"
        echo -e "${GREEN}✓${NC} tmux configuration installed from nvim config"
    else
        # If not in nvim config, check if it already exists in home
        if [ -f "$HOME/.tmux.conf" ]; then
            echo -e "${GREEN}✓${NC} tmux configuration already exists"
        else
            echo -e "${YELLOW}⚠${NC} No tmux configuration found to install"
        fi
    fi
    
    # Install TPM (Tmux Plugin Manager) if not already installed
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo -e "${YELLOW}→${NC} Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        echo -e "${GREEN}✓${NC} TPM installed"
    else
        echo -e "${GREEN}✓${NC} TPM is already installed"
    fi
    
    # Install catppuccin tmux plugin directory if needed
    mkdir -p "$HOME/.config/tmux/plugins"
    if [ ! -d "$HOME/.config/tmux/plugins/catppuccin" ]; then
        echo -e "${YELLOW}→${NC} Installing Catppuccin tmux theme..."
        git clone https://github.com/catppuccin/tmux.git "$HOME/.config/tmux/plugins/catppuccin"
        echo -e "${GREEN}✓${NC} Catppuccin theme installed"
    else
        echo -e "${GREEN}✓${NC} Catppuccin theme is already installed"
    fi
    
    # Install tmux-cpu plugin
    if [ ! -d "$HOME/.config/tmux/plugins/tmux-plugins/tmux-cpu" ]; then
        echo -e "${YELLOW}→${NC} Installing tmux-cpu plugin..."
        mkdir -p "$HOME/.config/tmux/plugins/tmux-plugins"
        git clone https://github.com/tmux-plugins/tmux-cpu.git "$HOME/.config/tmux/plugins/tmux-plugins/tmux-cpu"
        echo -e "${GREEN}✓${NC} tmux-cpu plugin installed"
    else
        echo -e "${GREEN}✓${NC} tmux-cpu plugin is already installed"
    fi
    
    # Install tmux-battery plugin
    if [ ! -d "$HOME/.config/tmux/plugins/tmux-plugins/tmux-battery" ]; then
        echo -e "${YELLOW}→${NC} Installing tmux-battery plugin..."
        mkdir -p "$HOME/.config/tmux/plugins/tmux-plugins"
        git clone https://github.com/tmux-plugins/tmux-battery.git "$HOME/.config/tmux/plugins/tmux-plugins/tmux-battery"
        echo -e "${GREEN}✓${NC} tmux-battery plugin installed"
    else
        echo -e "${GREEN}✓${NC} tmux-battery plugin is already installed"
    fi
    
    echo -e "${GREEN}✓${NC} tmux setup completed"
    echo ""
    echo "Note: To activate the tmux configuration:"
    echo "  • If tmux is running: run 'tmux source-file ~/.tmux.conf'"
    echo "  • For colored undercurls: restart tmux completely with 'tmux kill-server && tmux'"
fi

echo ""
echo "=== Additional Development Tools ==="
echo ""

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
echo "  • Terminal: tmux"
echo "  • Utilities: curl, wget, unzip, tar, gzip"
echo "  • Optional: lazygit"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
echo "  2. Add ~/.local/bin to PATH if not already (for fd and other tools)"
echo "  3. Open Neovim and run: :checkhealth"
echo "  4. Install LSP servers with: :Mason"
echo ""
