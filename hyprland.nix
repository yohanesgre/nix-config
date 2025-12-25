{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in
lib.mkIf isLinux {
  # Hypridle - idle management daemon for Hyprland
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session && sleep 1";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };
      listener = [
        {
          timeout = 1800;  # 30 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 2100;  # 35 minutes (5 min after display off)
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 3600;  # 60 minutes
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # Hyprlock - screen lock for Hyprland
  # Disabled: Using system hyprlock to match system Hyprland
  programs.hyprlock = {
    enable = false;
    settings = {
      general = {
        hide_cursor = true;
      };

      background = [{
        monitor = "";
        path = "~/.config/hypr/wallpapers/pexels-simon73-1183099.jpg";
        blur_passes = 3;
        blur_size = 7;
        brightness = 0.8;
        contrast = 0.9;
      }];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color = "rgb(255, 255, 255)";
          font_size = 90;
          font_family = "Inter";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:60000] echo "$(date +"%A, %B %e")"'';
          color = "rgb(255, 255, 255)";
          font_size = 24;
          font_family = "Inter";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        # User
        {
          monitor = "";
          text = "$USER";
          color = "rgb(255, 255, 255)";
          font_size = 16;
          font_family = "Inter";
          position = "0, -170";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [{
        monitor = "";
        size = "300, 50";
        outline_thickness = 3;
        dots_size = 0.25;
        dots_spacing = 0.3;
        dots_center = true;
        outer_color = "rgba(33, 150, 243, 0.7)";
        inner_color = "rgba(0, 0, 0, 0.6)";
        font_color = "rgb(255, 255, 255)";
        check_color = "rgb(33, 150, 243)";
        fail_color = "rgb(244, 67, 54)";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "rgb(255, 193, 7)";
        fade_on_empty = true;
        fade_timeout = 1000;
        placeholder_text = ''<span foreground="##FFFFFF99">Enter password...</span>'';
        position = "0, -100";
        halign = "center";
        valign = "center";
      }];
    };
  };

  # Enable Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # Use system Hyprland instead of Nix package
    xwayland.enable = true;

    # Portal configuration - only use in Hyprland sessions
    systemd = {
      enable = true;
      variables = ["--all"];
    };

    settings = {
      # Program variables
      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$menu" = "rofi -show drun";
      "$browser" = "flatpak run app.zen_browser.zen";
      "$mainMod" = "SUPER";
      "$scriptsDir" = "~/.config/hypr/scripts";

      # Monitor configuration
      # Using auto-detection (empty name) to handle monitor name changes on reload
      monitor = ",2560x1440@60,auto,1";

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "QT_QPA_PLATFORMTHEME,qt6ct"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = false;
        };
      };

      # Device-specific configuration
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # General settings
      general = {
        gaps_in = 8;
        gaps_out = 8;
        border_size = 1;
        "col.active_border" = "rgba(6750A4ff) rgba(D0BCFF88) 45deg";
        "col.inactive_border" = "rgba(49454Faa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration settings
      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 0.95;

        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
          color = "rgba(000000cc)";
          offset = "0 4";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          vibrancy = 0.2;
          brightness = 1.0;
          contrast = 1.0;
        };
      };

      # Animations
      animations = {
        enabled = false;
      };

      # Dwindle layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout
      master = {
        new_status = "master";
      };

      # Misc settings
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      # Window rules
      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      # Window rules v2 (more powerful matching)
      windowrulev2 = [
        # Firefox/Zen Browser Picture-in-Picture
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "size 25% 25%, title:^(Picture-in-Picture)$"
        "move 74% 74%, title:^(Picture-in-Picture)$"
        "keepaspectratio, title:^(Picture-in-Picture)$"
        "opacity 1.0 override, title:^(Picture-in-Picture)$"
        "noborder, title:^(Picture-in-Picture)$"

        # File picker dialogs (GTK/GNOME)
        "float, class:^(org.gnome.Nautilus)$,title:^(Open)(.*)$"
        "float, class:^(org.gnome.Nautilus)$,title:^(Save)(.*)$"
        "float, class:^(xdg-desktop-portal-gtk)$"
        "size 60% 70%, class:^(xdg-desktop-portal-gtk)$"
        "center, class:^(xdg-desktop-portal-gtk)$"
      ];

      # Layer rules
      layerrule = [
        "blur,vicinae"
        "ignorealpha 0, vicinae"
        "noanim, vicinae"
        "noanim, wlogout"
        "blur, wlogout"
        "ignorealpha 0.2, wlogout"
      ];

      # Autostart
      exec-once = [
        "waybar"
        "vicinae server"
        "~/.config/hypr/scripts/wallpaper.sh"
        "swaync"
        "systemctl --user start idle-scheduler.service"
        "hyprsession"
        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
      ];

      # Keybindings
      bind = [
        # Application launches
        "$mainMod, Return, exec, $terminal"
        "$mainMod, W, killactive,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, B, exec, $browser"
        "$mainMod, V, togglefloating,"
        "$mainMod, D, exec, $menu"
        "$mainMod SHIFT, R, exec, hyprctl reload && pkill waybar && waybar && pkill swaync && swaync && swaync-client --reload-config && swaync-client --reload-css"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, Space, exec, vicinae toggle"
        "$mainMod SHIFT, W, exec, $scriptsDir/wallpaper-picker.sh"
        "$mainMod ALT, W, exec, $scriptsDir/wallpaper-cycle.sh"
        "$mainMod SHIFT, M, exit,"

        # Screenshots
        ", Print, exec, grim - | swappy -f -"
        "$mainMod, Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mainMod SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Display resolution picker
        "$mainMod SHIFT, D, exec, $scriptsDir/display-picker.sh"

        # Notification center
        "$mainMod, N, exec, swaync-client -t -sw"

        # Idle scheduler config
        "$mainMod SHIFT, I, exec, $terminal -e ~/.config/idle-scheduler/idle-scheduler-config.sh"

        # Window management
        "$mainMod, F, fullscreen, 0"

        # Move focus with arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Move windows with SHIFT + arrow keys
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Resize windows with CTRL + arrow keys
        "$mainMod CTRL, left, resizeactive, -40 0"
        "$mainMod CTRL, right, resizeactive, 40 0"
        "$mainMod CTRL, up, resizeactive, 0 -40"
        "$mainMod CTRL, down, resizeactive, 0 40"

        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Session management
        "$mainMod SHIFT, L, exec, hyprlock"
        "$mainMod, Escape, exec, wlogout"
      ];

      # Mouse bindings for moving/resizing
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Multimedia and brightness keys
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # Media player controls
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };

  # Configure XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    config = {
      # Configuration for Hyprland sessions
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
      # Fallback configuration for other sessions (like KDE Plasma)
      common = {
        default = [ "gtk" ];
      };
    };
  };

  # Prevent xdg-desktop-portal-hyprland from running in non-Hyprland sessions
  # This prevents conflicts with KDE Plasma's portal using systemd drop-in
  xdg.configFile."systemd/user/xdg-desktop-portal-hyprland.service.d/override.conf".text = ''
    [Unit]
    # Only start if we're in Hyprland session
    ConditionEnvironment=XDG_CURRENT_DESKTOP=Hyprland
    # Bind to graphical session - stops when session ends
    PartOf=graphical-session.target

    [Service]
    # Don't restart if it fails or stops
    Restart=no
  '';

  # Keep scripts, wallpapers, and other configuration files
  home.file = {
    # Wallpapers
    ".config/hypr/wallpapers" = {
      source = ./dotfiles/hypr/wallpapers;
      recursive = true;
    };

    # Scripts
    ".config/hypr/scripts/wallpaper.sh" = {
      source = ./dotfiles/hypr/scripts/wallpaper.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper-cycle.sh" = {
      source = ./dotfiles/hypr/scripts/wallpaper-cycle.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper-picker.sh" = {
      source = ./dotfiles/hypr/scripts/wallpaper-picker.sh;
      executable = true;
    };
    ".config/hypr/scripts/display-picker.sh" = {
      source = ./dotfiles/hypr/scripts/display-picker.sh;
      executable = true;
    };

    # Wlogout configuration
    ".config/wlogout/layout".source = ./dotfiles/wlogout/layout;
    ".config/wlogout/style.css".source = ./dotfiles/wlogout/style.css;

    # Swappy configuration
    ".config/swappy/config".source = ./dotfiles/swappy/config;

    # Rofi configuration
    ".config/rofi/config.rasi".source = ./dotfiles/rofi/config.rasi;

    # SwayNC configuration
    ".config/swaync/config.json".source = ./dotfiles/swaync/config.json;
    ".config/swaync/style.css".source = ./dotfiles/swaync/style.css;

    # Waybar configuration
    ".config/waybar/config.jsonc".source = ./dotfiles/waybar/config.jsonc;
    ".config/waybar/style.css".source = ./dotfiles/waybar/style.css;
    ".config/waybar/scripts/power-monitor.sh" = {
      source = ./dotfiles/waybar/scripts/power-monitor.sh;
      executable = true;
    };
    ".config/waybar/scripts/power-profile.sh" = {
      source = ./dotfiles/waybar/scripts/power-profile.sh;
      executable = true;
    };
    ".config/waybar/scripts/idle-scheduler.sh" = {
      source = ./dotfiles/waybar/scripts/idle-scheduler.sh;
      executable = true;
    };

    # Idle scheduler scripts
    ".config/idle-scheduler/idle-scheduler-daemon.sh" = {
      source = ./dotfiles/idle-scheduler/idle-scheduler-daemon.sh;
      executable = true;
    };
    ".config/idle-scheduler/idle-scheduler-config.sh" = {
      source = ./dotfiles/idle-scheduler/idle-scheduler-config.sh;
      executable = true;
    };

    # Systemd user services
    ".config/systemd/user/idle-scheduler.service".source = ./dotfiles/systemd/idle-scheduler.service;
  };
}
