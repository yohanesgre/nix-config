{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in
lib.mkIf isLinux {
  # Hyprland configuration files
  home.file = {
    # Main config
    ".config/hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;

    # Modular configs
    ".config/hypr/monitors.conf".source = ./dotfiles/hypr/monitors.conf;
    ".config/hypr/environment.conf".source = ./dotfiles/hypr/environment.conf;
    ".config/hypr/appearance.conf".source = ./dotfiles/hypr/appearance.conf;
    ".config/hypr/input.conf".source = ./dotfiles/hypr/input.conf;
    ".config/hypr/keybindings.conf".source = ./dotfiles/hypr/keybindings.conf;
    ".config/hypr/windowrules.conf".source = ./dotfiles/hypr/windowrules.conf;
    ".config/hypr/autostart.conf".source = ./dotfiles/hypr/autostart.conf;

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

    # Swayidle configuration
    ".config/swayidle/config".source = ./dotfiles/swayidle/config;

    # Swaylock configuration
    ".config/swaylock/config".source = ./dotfiles/swaylock/config;

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
  };

}
