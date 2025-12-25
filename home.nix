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
  enableRoyuanKeyboard = userConfig.enableRoyuanKeyboard or false;
  freshInstall = userConfig.freshInstall or false;
in
{
  # Import Hyprland configuration on Linux
  imports = [
    ./hyprland.nix
  ];

  # Home Manager configuration
  home.username = username;
  home.homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "24.11";


  # Packages to install
  home.packages = with pkgs; [
    # Nix-specific packages (always install via Nix)
    claude-code
    nix-index
    fastfetch
  ] ++ lib.optionals isDarwin [
    # macOS: Install all packages via Nix (no pacman available)
    btop
    curl
    fzf
    gh
    ghostty
    git
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    unzip
    vim
    vscode
    xz
    zip
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
  ] ++ lib.optionals isLinux [
    # Linux (Arch/CachyOS): CLI tools and utilities via Nix
    # GUI apps and system packages remain in pacman

    # Core CLI utilities
    git
    curl
    vim
    unzip
    zip
    xz
    usbutils

    # Development tools
    gh
    btop
    fzf
    yazi
    ffmpegthumbnailer
    zoxide
    tmux

    # Wayland CLI utilities
    wl-clipboard
    cliphist
    grim
    slurp

    # TUI tools
    gum

    # Fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    font-awesome

    # Zsh plugins (managed by programs.zsh, but available as packages)
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
    # Automatically sync all scripts from scripts/ to .local/bin
    (let
      scriptsDir = ./scripts;
      scriptFiles = builtins.readDir scriptsDir;
      # Create home.file entries for all .sh files in scripts/
      scriptEntries = lib.mapAttrs' (name: type:
        if type == "regular" && lib.hasSuffix ".sh" name then
          lib.nameValuePair ".local/bin/${lib.removeSuffix ".sh" name}" {
            source = scriptsDir + "/${name}";
            executable = true;
          }
        else
          lib.nameValuePair "" {} # Skip non-.sh files
      ) scriptFiles;
      # Filter out empty entries
      filteredEntries = lib.filterAttrs (n: v: n != "") scriptEntries;
    in filteredEntries)
    (lib.mkIf enableFlutter {
      # Create Developments directory structure
      "Developments/Sdk/.keep" = {
        text = "# This directory contains development SDKs\n";
      };
    })
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    HISTCONTROL = "ignoreboth";
    HISTIGNORE = "&:[bf]g:c:clear:history:exit:q:pwd:* --help";
    LESS_TERMCAP_md = "$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)";
    LESS_TERMCAP_me = "$(tput sgr0 2> /dev/null)";
  } // lib.optionalAttrs isDarwin {
    # macOS-specific settings
    TERMINAL = "ghostty";
  } // lib.optionalAttrs isLinux {
    # Linux (Arch): Arch Linux integration (from Arch Wiki)
    LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
    # Note: XDG_DATA_DIRS is set in zsh initExtra to override system scripts
  } // {
    # Cross-platform: Use Nix-provided FZF
    FZF_BASE = "${pkgs.fzf}/share/fzf";
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
    userName = userConfig.gitUserName or "";
    userEmail = userConfig.gitUserEmail or "";
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

      # Home-manager shortcuts (platform-aware)
      hm = if isLinux
        then "home-manager switch --flake ~/.config/nix#archlinux"
        else "home-manager switch --flake ~/.config/nix#macos";
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

      ${lib.optionalString isLinux ''
        # Fix XDG_DATA_DIRS ordering for Linux
        # System paths must come first so Plasma and other system packages work correctly
        # This runs AFTER all profile.d scripts (Flatpak, Nix daemon, etc)
        export XDG_DATA_DIRS="/usr/local/share:/usr/share:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share"
      ''}

      # Load zsh-history-substring-search (Nix-provided on both platforms)
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

      # Bind keys for history substring search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # Add local bin to PATH
      export PATH="$HOME/.local/bin:$PATH"

      # Yazi - smart cd on quit (now using Nix-provided yazi)
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

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
      # Auto-run: Setup SSH key (first time only)
      autoSetupSshKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
        SSH_KEY_FILE="${config.home.homeDirectory}/.ssh/id_ed25519"
        if [ ! -f "$SSH_KEY_FILE" ]; then
          echo "🔑 No SSH key found, running setup-ssh-key..."
          $DRY_RUN_CMD ${config.home.homeDirectory}/.local/bin/setup-ssh-key || echo "⚠️  SSH setup failed or skipped"
        fi
      '';
    }
    (lib.mkIf isLinux {
      # Auto-run: Install Arch packages (first time only)
      # This must run after writeBoundary to ensure scripts are symlinked
      autoInstallArchPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
        MARKER_FILE="${config.home.homeDirectory}/.local/share/nix-home-manager/arch-packages-installed"
        FRESH_INSTALL=${if freshInstall then "true" else "false"}

        # Check if script exists before attempting to run
        if [ ! -f "${config.home.homeDirectory}/.local/bin/install-arch-packages" ]; then
          echo "⚠️  install-arch-packages script not found, skipping..."
        elif [ ! -f "$MARKER_FILE" ] || [ "$FRESH_INSTALL" = "true" ]; then
          if [ "$FRESH_INSTALL" = "true" ]; then
            echo "📦 Fresh install requested: Installing Arch packages..."
          else
            echo "📦 First-time setup: Installing Arch packages..."
          fi

          if AUTO_MODE=true $DRY_RUN_CMD ${config.home.homeDirectory}/.local/bin/install-arch-packages; then
            mkdir -p "$(dirname "$MARKER_FILE")"
            touch "$MARKER_FILE"
            echo "✅ Arch packages installed"
          else
            echo "⚠️  Package installation failed. Run manually: install-arch-packages.sh"
          fi
        fi
      '';

      # Auto-run: Fix ROYUAN keyboard (Linux only, if enabled)
      # This must run after autoInstallArchPackages to ensure usbutils is installed
      autoFixKeyboard = lib.mkIf enableRoyuanKeyboard (lib.hm.dag.entryAfter ["autoInstallArchPackages"] ''
        if [ -f "${config.home.homeDirectory}/.local/bin/fix-royuan-keyboard" ]; then
          echo "⌨️  Applying ROYUAN keyboard fixes..."
          $DRY_RUN_CMD ${config.home.homeDirectory}/.local/bin/fix-royuan-keyboard || echo "⚠️  Keyboard fix failed"
        fi
      '');

      # Auto-run: Setup RAPL permissions for CPU power monitoring (Linux only, first time)
      autoSetupRaplPermissions = lib.hm.dag.entryAfter ["autoInstallArchPackages"] ''
        RAPL_MARKER="${config.home.homeDirectory}/.local/share/nix-home-manager/rapl-configured"
        if [ ! -f "$RAPL_MARKER" ] && [ -f "${config.home.homeDirectory}/.local/bin/setup-rapl-permissions" ]; then
          echo "⚡ Setting up CPU power monitoring..."
          if $DRY_RUN_CMD ${config.home.homeDirectory}/.local/bin/setup-rapl-permissions; then
            mkdir -p "$(dirname "$RAPL_MARKER")"
            touch "$RAPL_MARKER"
          else
            echo "⚠️  RAPL setup failed or skipped"
          fi
        fi
      '';

      # Auto-run: Setup nwg-look symlinks (Linux only, every time to ensure compatibility)
      autoSetupNwgLook = lib.hm.dag.entryAfter ["autoInstallArchPackages"] ''
        if [ -f "${config.home.homeDirectory}/.local/bin/setup-nwg-look" ]; then
          echo "🎨 Setting up nwg-look compatibility..."
          $DRY_RUN_CMD ${config.home.homeDirectory}/.local/bin/setup-nwg-look || echo "⚠️  nwg-look setup failed"
        fi
      '';
    })
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
