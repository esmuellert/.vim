# Home Manager configuration for Neovim development environment
# This file mirrors the dependencies from scripts/install-deps-linux.sh
#
# Usage (copy-paste each step):
#
#   1. Install Nix:
#      sh <(curl -L https://nixos.org/nix/install) --daemon && source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
#
#   2. Install Home Manager and neovim-nightly channel:
#      nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && nix-channel --add https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz neovim-nightly && nix-channel --update && nix-shell '<home-manager>' -A install
#
#   3. Clone this repo:
#      git clone https://github.com/esmuellert/.vim.git ~/.config/nvim
#
#   4. Link config:
#      ln -sf ~/.config/nvim/home.nix ~/.config/home-manager/home.nix
#
#   5. Apply:
#      home-manager switch
#
#   6. Set zsh as default shell (log out/in after):
#      echo $(which zsh) | sudo tee -a /etc/shells && chsh -s $(which zsh)
#
# To update packages: nix-channel --update && home-manager switch
# To update neovim nightly: nix-channel --update neovim-nightly && home-manager switch
#
# Local packages (optional):
#   Create ~/.config/home-manager/local.nix to add machine-specific packages:
#   { pkgs, ... }: { home.packages = with pkgs; [ slack discord ]; }

{ config, pkgs, ... }:

let
  # Neovim nightly overlay (from channel - update with: nix-channel --update neovim-nightly)
  neovim-nightly-overlay = import <neovim-nightly>;

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

  # Local config file for machine-specific packages (optional)
  # Create ~/.config/home-manager/local.nix with: { pkgs, ... }: { home.packages = with pkgs; [ ... ]; }
  localConfigPath = builtins.getEnv "HOME" + "/.config/home-manager/local.nix";
  hasLocalConfig = builtins.pathExists localConfigPath;

in
{
  imports = if hasLocalConfig then [ localConfigPath ] else [];

  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

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
    gh             # GitHub CLI

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
    gawk       # awk - needed for tmux plugin manager

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

    # === File Manager ===
    yazi
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
    settings = {
      credential."https://github.com" = {
        helper = "!gh auth git-credential";
      };
    };
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

  # Yazi file manager configuration
  xdg.configFile."yazi/yazi.toml".text = ''
[mgr]
show_hidden = true
sort_dir_first = true
sort_by = "natural"
sort_sensitive = false
linemode = "size"

[[plugin.prepend_fetchers]]
id = "git"
url = "*"
run = "git"

[[plugin.prepend_fetchers]]
id = "git"
url = "*/"
run = "git"
'';

  xdg.configFile."yazi/init.lua".text = ''
require("git"):setup {
  order = 1500,
}

require("full-border"):setup {
  type = ui.Border.ROUNDED,
}
'';

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

  # =========================================
  # Activation scripts (run on home-manager switch)
  # =========================================
  home.activation.fnmSetup = config.lib.dag.entryAfter ["writeBoundary"] ''
    export PATH="$HOME/.nix-profile/bin:$PATH"
    if command -v fnm &> /dev/null; then
      if ! fnm list 2>/dev/null | grep -qE 'v[0-9]'; then
        echo "Installing Node.js LTS via fnm..."
        fnm install --lts && fnm default lts-latest
      else
        echo "Node.js already installed via fnm, skipping LTS setup"
      fi
    else
      echo "fnm not found, skipping Node.js setup"
    fi
  '';

  home.activation.tpmSetup = config.lib.dag.entryAfter ["linkGeneration"] ''
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    
    if [ ! -d "$TPM_DIR" ]; then
      echo "Installing TPM (Tmux Plugin Manager)..."
      git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
      echo "Run 'prefix + I' in tmux to install plugins"
    else
      echo "TPM already installed, skipping"
    fi
  '';

  home.activation.yaziPlugins = config.lib.dag.entryAfter ["writeBoundary"] ''
    export PATH="$HOME/.nix-profile/bin:$PATH"
    if command -v ya &> /dev/null; then
      ya pkg add yazi-rs/plugins:git 2>/dev/null || true
      ya pkg add yazi-rs/plugins:full-border 2>/dev/null || true
    fi
  '';
}
