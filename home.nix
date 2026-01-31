# Home Manager configuration for Neovim development environment
# This file mirrors the dependencies from scripts/install-deps-linux.sh
#
# Usage:
#   1. Install Nix: sh <(curl -L https://nixos.org/nix/install) --daemon
#   2. Install Home Manager:
#      nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
#      nix-channel --update
#      nix-shell '<home-manager>' -A install
#   3. Link or copy this file: ln -sf ~/.config/nvim/home.nix ~/.config/home-manager/home.nix
#   4. Apply: home-manager switch
#
# To update packages: nix-channel --update && home-manager switch
# To update neovim nightly: home-manager switch (fetches latest from overlay)

{ config, pkgs, ... }:

let
  # Neovim nightly overlay (auto-updates from nix-community)
  neovim-nightly-overlay = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
  });

  # Apply overlay to get neovim-nightly
  pkgsWithNeovim = import <nixpkgs> {
    overlays = [ neovim-nightly-overlay ];
  };

  # Custom theme (not in nixpkgs, fetch from GitHub)
  zsh-material-deep-ocean = builtins.fetchTarball {
    url = "https://github.com/esmuellert/material-deep-ocean-zsh/archive/main.tar.gz";
  };

  # Build custom Oh My Zsh directory with theme
  # Plugins come from nixpkgs (zsh-autosuggestions, zsh-syntax-highlighting)
  ohmyzsh-custom = pkgs.stdenv.mkDerivation {
    name = "ohmyzsh-custom";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/themes \
               $out/plugins/zsh-autosuggestions \
               $out/plugins/zsh-syntax-highlighting

      cp ${zsh-material-deep-ocean}/material_deep_ocean.zsh-theme $out/themes/

      cat > $out/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh <<'EOF'
source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
EOF

      cat > $out/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh <<'EOF'
source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF
    '';
  };

in
{
  home.username = "yanuoma";
  home.homeDirectory = "/home/yanuoma";

  # Don't change this after initial setup
  home.stateVersion = "24.05";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # =========================================
  # Packages (from install-deps-linux.sh)
  # =========================================
  home.packages = with pkgs; [
    # === Core Build Tools ===
    gcc
    gnumake
    cmake
    pkg-config

    # === Version Control ===
    git

    # === Download Tools ===
    curl
    wget

    # === Archive Tools ===
    unzip
    gnutar
    gzip

    # === Search Tools (for Telescope) ===
    ripgrep    # rg - required for telescope live_grep
    fd         # better file finder
    fzf        # fuzzy finder
    bat        # cat with syntax highlighting

    # === Terminal Multiplexer ===
    tmux

    # === Shell ===
    zsh

    # === Neovim ===
    pkgsWithNeovim.neovim  # Nightly from nix-community overlay

    # === Additional Development Tools ===
    lazygit
    stylua     # Lua formatter

    # === Tree-sitter (parsers are handled by nvim-treesitter plugin) ===
    tree-sitter

    # === Node.js Version Manager ===
    fnm        # Fast Node Manager - manages Node versions

    # === AI Coding Agent ===
    opencode
  ];

  # =========================================
  # Program-specific configurations
  # =========================================

  # Git configuration (optional - customize as needed)
  programs.git = {
    enable = true;
    # Uncomment and customize:
    # userName = "Your Name";
    # userEmail = "your.email@example.com";
  };

  # Zsh configuration - using Oh My Zsh with material-deep-ocean theme
  # Theme from: https://github.com/esmuellert/material-deep-ocean-zsh
  programs.zsh = {
    enable = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "material_deep_ocean";  # Custom theme installed separately
      plugins = [ "git" "zsh-autosuggestions" "zsh-syntax-highlighting" ];
      custom = "${ohmyzsh-custom}";  # Nix-managed custom plugins/themes
    };

    # Source Nix daemon for non-login shells (e.g., wsl.exe commands)
    envExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';

    # Extra config at the end of .zshrc
    initContent = ''
      # fnm (Node version manager) - installed via Nix
      if command -v fnm &> /dev/null; then
        eval "$(fnm env --use-on-cd)"
      fi

      # pnpm
      export PNPM_HOME="$HOME/.local/share/pnpm"
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac

      # GitHub token
      # if command -v gh &> /dev/null; then
      #   export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
      # fi

      # cargo/rust
      export PATH="$HOME/.cargo/bin:$PATH"
    '';
  };

  # tmux - just symlink our config directly (no Home Manager defaults)
  # Plugins are managed by TPM (installed at ~/.tmux/plugins/tpm)
  home.file.".tmux.conf".source = ./.tmux.conf;

  # fzf integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # =========================================
  # Environment variables
  # =========================================
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # =========================================
  # Add ~/.local/bin to PATH
  # =========================================
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
