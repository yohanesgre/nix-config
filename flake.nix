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
      # CUSTOMIZE THIS: Set your username here
      username = "yohanes";

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
      # Linux configurations
      homeConfigurations."${username}@linux" = mkHomeConfiguration "x86_64-linux" systems.x86_64-linux;
      homeConfigurations."${username}@linux-arm" = mkHomeConfiguration "aarch64-linux" systems.aarch64-linux;

      # macOS configurations
      homeConfigurations."${username}@darwin" = mkHomeConfiguration "x86_64-darwin" systems.x86_64-darwin;
      homeConfigurations."${username}@darwin-arm" = mkHomeConfiguration "aarch64-darwin" systems.aarch64-darwin;

      # Default configuration (backwards compatibility)
      homeConfigurations."${username}" = mkHomeConfiguration "x86_64-linux" systems.x86_64-linux;
    };
}
