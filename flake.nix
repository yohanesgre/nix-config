{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { nixpkgs, home-manager, nix-flatpak, ... }:
    let
      # Helper function to create home configuration for a system
      mkHomeConfiguration = system: pkgs: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
        ] ++ (if pkgs.stdenv.isLinux then [
          nix-flatpak.homeManagerModules.nix-flatpak
        ] else []);
      };

      # Define systems
      systems = {
        x86_64-linux = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        aarch64-linux = import nixpkgs {
          system = "aarch64-linux";
          config.allowUnfree = true;
        };
        x86_64-darwin = import nixpkgs {
          system = "x86_64-darwin";
          config.allowUnfree = true;
        };
        aarch64-darwin = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
      };
    in {
      homeConfigurations = {
        # Platform-specific profiles
        archlinux = mkHomeConfiguration "x86_64-linux" systems.x86_64-linux;
        archlinux-arm = mkHomeConfiguration "aarch64-linux" systems.aarch64-linux;
        macos = mkHomeConfiguration "aarch64-darwin" systems.aarch64-darwin;
        macos-intel = mkHomeConfiguration "x86_64-darwin" systems.x86_64-darwin;

        # Default configuration (x86_64 Linux / Arch)
        default = mkHomeConfiguration "x86_64-linux" systems.x86_64-linux;
      };
    };
}
