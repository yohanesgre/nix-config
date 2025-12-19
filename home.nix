{ config, pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # Home Manager configuration
  home.username = "yohanes";
  home.homeDirectory = if isDarwin then "/Users/yohanes" else "/home/yohanes";
  home.stateVersion = "24.11";

  # Packages to install
  home.packages = with pkgs; [
    # Cross-platform packages
    btop
    claude-code
    fastfetch
    fzf
    gh
    ghostty
    git
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nix-index
    vim
    vscode
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
  ] ++ lib.optionals isLinux [
    # Linux-only packages
    flatpak
    protontricks
    steam
    wine
    winetricks
  ];

  # Dotfiles management
  home.file = lib.mkMerge [
    {
      # Common files for all platforms
    }
    {
      # SSH key setup script (all platforms)
      ".local/bin/setup-ssh-key" = {
        source = ./scripts/setup-ssh-key.sh;
        executable = true;
      };
    }
    (lib.mkIf isLinux {
      # ROYUAN OLV75 Keyboard fix script (Linux only)
      ".local/bin/fix-royuan-keyboard" = {
        source = ./scripts/fix-royuan-keyboard.sh;
        executable = true;
      };
    })
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    FZF_BASE = "${pkgs.fzf}/share/fzf";
    HISTCONTROL = "ignoreboth";
    HISTIGNORE = "&:[bf]g:c:clear:history:exit:q:pwd:* --help";
    LESS_TERMCAP_md = "$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)";
    LESS_TERMCAP_me = "$(tput sgr0 2> /dev/null)";
    TERMINAL = "ghostty";
  };

  # Programs configuration
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.email = "yohanesgre@gmail.com";
      user.name = "Yohanes Grethaputra";
    };
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      palette = "catppuccin_mocha";

      # Character configuration
      character = {
        success_symbol = "[[󰄛](green) ❯](peach)";
        error_symbol = "[[󰄛](red) ❯](peach)";
        vimcmd_symbol = "[󰄛 ❮](subtext1)";
      };

      # Directory configuration
      directory = {
        truncation_length = 4;
        style = "bold lavender";
      };

      # Git branch
      git_branch = {
        style = "bold mauve";
      };

      # Catppuccin Mocha palette
      palettes.catppuccin_mocha = {
        base = "#1e1e2e";
        blue = "#89b4fa";
        crust = "#11111b";
        flamingo = "#f2cdcd";
        green = "#a6e3a1";
        lavender = "#b4befe";
        mantle = "#181825";
        maroon = "#eba0ac";
        mauve = "#cba6f7";
        overlay0 = "#6c7086";
        overlay1 = "#7f849c";
        overlay2 = "#9399b2";
        peach = "#fab387";
        pink = "#f5c2e7";
        red = "#f38ba8";
        rosewater = "#f5e0dc";
        sapphire = "#74c7ec";
        sky = "#89dceb";
        subtext0 = "#a6adc8";
        subtext1 = "#bac2de";
        surface0 = "#313244";
        surface1 = "#45475a";
        surface2 = "#585b70";
        teal = "#94e2d5";
        text = "#cdd6f4";
        yellow = "#f9e2af";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # SSH config that will be synced across devices
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        user = "git";
      };
      "gitlab.com" = {
        identityFile = "~/.ssh/id_ed25519";
        user = "git";
      };
      # Add more hosts as needed
      "*" = {
        # Security settings
        addKeysToAgent = "yes";
        compression = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };

    # Additional SSH config
    extraConfig = ''
      # Prevent SSH from adding unknown hosts automatically
      StrictHostKeyChecking ask

      # Use the newer key exchange algorithms
      KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History configuration
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreSpace = true;
      ignoreDups = true;
      share = true;
    };

    # Oh-my-zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" "extract" ];
    };

    # Shell aliases
    shellAliases = {
      # Cross-platform aliases
      c = "clear";
      n = "ninja";

      # Home-manager shortcuts
      hm = "home-manager switch --flake ~/.config/nix#yohanes";
      hme = "$EDITOR ~/.config/nix/home.nix";
    } // lib.optionalAttrs isLinux {
      # Linux-only aliases (from CachyOS config)
      make = "make -j`nproc`";
      ninja = "ninja -j`nproc`";
      rmpkg = "sudo pacman -Rsn";
      cleanch = "sudo pacman -Scc";
      fixpacman = "sudo rm /var/lib/pacman/db.lck";
      update = "sudo pacman -Syu";

      # Cleanup orphaned packages
      cleanup = "sudo pacman -Rsn $(pacman -Qtdq)";

      # Get the error messages from journalctl
      jctl = "journalctl -p 3 -xb";

      # Recent installed packages
      rip = "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl";
    } // lib.optionalAttrs isDarwin {
      # macOS-only aliases
      make = "make -j`sysctl -n hw.ncpu`";
      ninja = "ninja -j`sysctl -n hw.ncpu`";
      update = "brew update && brew upgrade";
    };

    # Additional zsh configuration
    initContent = ''
      # Disable magic functions (from CachyOS config)
      DISABLE_MAGIC_FUNCTIONS="true"

      # Enable command auto-correction
      ENABLE_CORRECTION="true"

      # Display red dots whilst waiting for completion
      COMPLETION_WAITING_DOTS="true"

      # Load zsh-history-substring-search
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

      # Bind keys for history substring search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # Add local bin to PATH
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # Flatpak configuration (Linux only)
  services.flatpak = lib.mkIf isLinux {
    enable = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    packages = [
      "app.zen_browser.zen"
    ];
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
  };
}
