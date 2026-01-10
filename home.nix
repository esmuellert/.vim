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
# To update neovim nightly: update the hash, then home-manager switch

{ config, pkgs, ... }:

let
  # Neovim nightly - prebuilt binary from GitHub releases
  # Supports both x86_64 and aarch64 Linux
  nvimArch = if pkgs.stdenv.hostPlatform.isAarch64 then "arm64" else "x86_64";
  nvimHashes = {
    arm64 = "sha256-ZNmPwvumv7hko9LwaqwCYpi2JttWkodcPQ8HzKXY0w4=";
    x86_64 = "sha256-4yXwbAn7MMnJI/UPUF6fCeAAjRWp7JCa2hHugQhJv9s=";
  };

  neovim-nightly = pkgs.stdenv.mkDerivation {
    pname = "neovim-nightly";
    version = "nightly";
    src = pkgs.fetchurl {
      url = "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-${nvimArch}.tar.gz";
      hash = nvimHashes.${nvimArch};
    };
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out
      cp -r nvim-linux-${nvimArch}/* $out/
    '';
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
  };

  # Custom Oh My Zsh theme and plugins
  zsh-material-deep-ocean = pkgs.fetchFromGitHub {
    owner = "esmuellert";
    repo = "material-deep-ocean-zsh";
    rev = "main";
    sha256 = "sha256-lOsR+mAo7lKUUYGw1cM5goBVlc9PRvyHKV9oMpEmh0Y=";
  };

  zsh-autosuggestions = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-autosuggestions";
    rev = "master";
    sha256 = "sha256-KmkXgK1J6iAyb1FtF/gOa0adUnh1pgFsgQOUnNngBaE=";
  };

  zsh-syntax-highlighting = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = "master";
    sha256 = "sha256-KRsQEDRsJdF7LGOMTZuqfbW6xdV5S38wlgdcCM98Y/Q=";
  };

  # Build custom Oh My Zsh directory with theme and plugins
  ohmyzsh-custom = pkgs.stdenv.mkDerivation {
    name = "ohmyzsh-custom";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/themes $out/plugins
      cp ${zsh-material-deep-ocean}/material_deep_ocean.zsh-theme $out/themes/
      cp -r ${zsh-autosuggestions} $out/plugins/zsh-autosuggestions
      cp -r ${zsh-syntax-highlighting} $out/plugins/zsh-syntax-highlighting
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

    # === Terminal Multiplexer ===
    tmux

    # === Shell ===
    zsh

    # === Neovim ===
    neovim-nightly  # Built from neovim/neovim nightly tag

    # === Additional Development Tools ===
    lazygit
    stylua     # Lua formatter

    # === Tree-sitter (parsers are handled by nvim-treesitter plugin) ===
    tree-sitter

    # === Node.js Version Manager ===
    fnm        # Fast Node Manager - manages Node versions
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
      if command -v gh &> /dev/null; then
        export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
      fi

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
