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
    ".config/hypr/scripts" = {
      source = ./dotfiles/hypr/scripts;
      recursive = true;
    };

    # Wlogout configuration
    ".config/wlogout/layout".source = ./dotfiles/wlogout/layout;
    ".config/wlogout/style.css".source = ./dotfiles/wlogout/style.css;
  };

}
