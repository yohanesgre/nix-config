{ pkgs, lib, config, ... }:

let
  isLinux = pkgs.stdenv.isLinux;

  configFile = ./config.nix;
  userConfig = if builtins.pathExists configFile
    then import configFile
    else {};

  hyprlandMouseName = userConfig.hyprlandMouseName or null;
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
          timeout = 600;  # 10 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;  # 15 minutes
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };

  # Hyprlock - screen lock for Hyprland
  # Managed by system Hyprland package

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

      # Device-specific configuration (from config.nix)
      device = lib.mkIf (hyprlandMouseName != null) {
        name = hyprlandMouseName;
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

      # Window rules (v0.53+ syntax - anonymous format)
      windowrule = [
        # Suppress maximize events for all windows
        "match:class .*, suppress_event maximize"

        # Prevent focus on empty XWayland windows
        "match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pin false, no_initial_focus on"

        # Firefox/Zen Browser Picture-in-Picture
        "match:title ^(Picture-in-Picture)$, float on, pin on, size 25% 25%, move 74% 74%, keep_aspect_ratio on, opacity 1.0 override, border_size 0"

        # PipeWire Volume Control - floating popup
        "match:class ^(com.saivert.pwvucontrol)$, float on, size 360 550, move 100%-450 50, pin on"

        # File picker dialogs (GTK/GNOME)
        "match:class ^(org.gnome.Nautilus)$, match:title ^(Open|Save)(.*)$, float on"
        "match:class ^(xdg-desktop-portal-gtk)$, float on, size 60% 70%, center on"
      ];

      # Layer rules (v0.53+ syntax - anonymous format)
      layerrule = [
        "match:namespace vicinae, blur on"
        "match:namespace vicinae, ignore_alpha 0"
        "match:namespace vicinae, no_anim on"
        "match:namespace wlogout, blur on"
        "match:namespace wlogout, ignore_alpha 0.2"
        "match:namespace wlogout, no_anim on"
      ];

      # Autostart
      exec-once = [
        "~/.config/hypr/scripts/setup-rapl-permissions.sh"
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

        # Screen Capture
        "$mainMod CTRL, Print, exec, $scriptsDir/screen-record.sh screen"
        "$mainMod ALT, Print, exec, $scriptsDir/screen-record.sh region"
        "$mainMod ALT, R, exec, killall -s SIGINT wf-recorder"

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
    ".config/hypr/scripts/setup-rapl-permissions.sh" = {
      source = ./scripts/setup-rapl-permissions.sh;
      executable = true;
    };
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
    ".config/hypr/scripts/screen-record.sh" = {
      source = ./dotfiles/hypr/scripts/screen-record.sh;
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
