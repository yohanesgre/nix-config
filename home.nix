{ config, pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;

  # Load configuration from config.nix file if it exists
  configFile = ./config.nix;
  userConfig = if builtins.pathExists configFile
    then import configFile
    else {};

  # Optional package configuration
  # Can be set here or in config.nix file
  username =
    if userConfig ? username then userConfig.username
    else if builtins.getEnv "USER" != "" then builtins.getEnv "USER"
    else "user";
  enableFlutter = userConfig.enableFlutter or false;
  enableGaming = userConfig.enableGaming or false;
in
{
  # Home Manager configuration
  home.username = username;
  home.homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "24.11";


  # Packages to install
  home.packages = with pkgs; [
    # Nix-specific packages (not available/recommended via pacman)
    claude-code
    nix-index

    # Cross-platform packages (keep in Nix for version control)
    fastfetch

    # NOTE: The following packages should be installed via pacman instead:
    # - Core utilities: git, curl, vim, unzip, zip, xz
    # - Zsh plugins: zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search
    # - Development tools: gh, btop, fzf
    # - Gaming: wine, winetricks, steam, protontricks
    # - Fonts: ttf-firacode-nerd, ttf-jetbrains-mono-nerd, ttf-meslo-nerd (via pacman)
    # - GUI apps: vscode (visual-studio-code-bin via AUR)
    # - Terminals: ghostty (has OpenGL issues with Nix, install via AUR instead)
    #
    # Run: ~/.config/nix/scripts/install-arch-packages.sh
  ] ++ lib.optionals enableFlutter [
    # Flutter development environment
    jdk17
  ] ++ lib.optionals (isLinux && enableFlutter) [
    # Flutter development environment (Linux only)
    libglvnd
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
    (lib.mkIf enableFlutter {
      # Android SDK setup script (when Flutter is enabled)
      ".local/bin/setup-android-sdk" = {
        source = ./scripts/setup-android-sdk.sh;
        executable = true;
      };
      # Create Developments directory structure
      "Developments/Sdk/.keep" = {
        text = "# This directory contains development SDKs\n";
      };
    })
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    # FZF_BASE = "${pkgs.fzf}/share/fzf";  # Use system fzf from pacman
    FZF_BASE = "/usr/share/fzf";
    HISTCONTROL = "ignoreboth";
    HISTIGNORE = "&:[bf]g:c:clear:history:exit:q:pwd:* --help";
    LESS_TERMCAP_md = "$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)";
    LESS_TERMCAP_me = "$(tput sgr0 2> /dev/null)";
    # TERMINAL = "ghostty";  # Removed: install via pacman/AUR instead (OpenGL issues with Nix)
    # Arch Linux integration (from Arch Wiki)
    LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
  } // lib.optionalAttrs isLinux {
    # Desktop integration on Linux (from Arch Wiki)
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:$XDG_DATA_DIRS";
  } // lib.optionalAttrs enableFlutter {
    # Flutter/Android development environment variables
    JAVA_HOME = "${pkgs.jdk17}";
    ANDROID_HOME = "${config.home.homeDirectory}/Developments/Sdk/android-sdk";
    ANDROID_SDK_ROOT = "${config.home.homeDirectory}/Developments/Sdk/android-sdk";
    FLUTTER_ROOT = "${config.home.homeDirectory}/Developments/Sdk/flutter";
  };

  # Programs configuration
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
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
      hm = "home-manager switch --flake ~/.config/nix#default";
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

      # Load zsh-history-substring-search (from pacman installation)
      # Note: Install via: sudo pacman -S zsh-history-substring-search
      if [ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
        source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
        # Bind keys for history substring search
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      fi

      # Add local bin to PATH
      export PATH="$HOME/.local/bin:$PATH"

      # Git configuration (set these in your ~/.zshrc.local or similar)
      # export GIT_AUTHOR_EMAIL="your-email@example.com"
      # export GIT_AUTHOR_NAME="Your Name"
      # export GIT_COMMITTER_EMAIL="your-email@example.com"
      # export GIT_COMMITTER_NAME="Your Name"

      ${lib.optionalString enableFlutter ''
        # Flutter and Android SDK paths
        export PATH="$FLUTTER_ROOT/bin:$PATH"
        export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
        export PATH="$ANDROID_HOME/platform-tools:$PATH"
        export PATH="$ANDROID_HOME/build-tools/34.0.0:$PATH"

        ${lib.optionalString isDarwin ''
          # Ensure Xcode Command Line Tools are installed on macOS for Flutter
          if ! xcode-select -p &> /dev/null; then
            echo "Xcode Command Line Tools not found. Please run: xcode-select --install"
          fi
        ''}
      ''}
    '';
  };

  # Activation scripts
  home.activation = lib.mkMerge [
    {
      # Notify about available setup scripts
      showSetupScripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "📦 Setup scripts available in ~/.local/bin/:"
        $DRY_RUN_CMD ls -1 ${config.home.homeDirectory}/.local/bin/setup-* ${config.home.homeDirectory}/.local/bin/fix-* 2>/dev/null || true
      '';
    }
    (lib.mkIf enableFlutter {
      setupAndroidSdk = lib.hm.dag.entryAfter ["installPackages"] ''
        echo ""
        echo "🔧 Running Android SDK setup..."
        export PATH="${pkgs.jdk17}/bin:${pkgs.curl}/bin:${pkgs.unzip}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.coreutils}/bin:$PATH"
        export ANDROID_HOME="${config.home.homeDirectory}/Developments/Sdk/android-sdk"
        export ANDROID_SDK_ROOT="${config.home.homeDirectory}/Developments/Sdk/android-sdk"
        export ANDROID_CMDLINE_TOOLS_URL="${userConfig.androidCmdlineToolsUrl or "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"}"
        export FLUTTER_SDK_URL="${userConfig.flutterSdkUrl or "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz"}"
        export JAVA_HOME="${pkgs.jdk17}"
        $DRY_RUN_CMD ${config.home.homeDirectory}/.local/bin/setup-android-sdk || echo "⚠️  Android SDK setup failed. You can run 'setup-android-sdk' manually later."
        echo ""
      '';
    })
  ];

  # Flatpak configuration disabled - use system flatpak instead
  # Install flatpak apps via: flatpak install flathub app.zen_browser.zen
}
