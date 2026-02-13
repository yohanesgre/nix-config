{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      commonConfig = { allowUnfree = true; };

      lib = nixpkgs.lib;

      mkPkgs = system: import nixpkgs {
        inherit system;
        config = commonConfig;
      };

      mkHomeConfiguration = system: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
    in {
      homeConfigurations = {
        archlinux = mkHomeConfiguration "x86_64-linux" (mkPkgs "x86_64-linux");
        archlinux-arm = mkHomeConfiguration "aarch64-linux" (mkPkgs "aarch64-linux");
        macos = mkHomeConfiguration "aarch64-darwin" (mkPkgs "aarch64-darwin");
        macos-intel = mkHomeConfiguration "x86_64-darwin" (mkPkgs "x86_64-darwin");
        default = mkHomeConfiguration "x86_64-linux" (mkPkgs "x86_64-linux");
      };

      nixConfig = {
        experimental-features = [ "nix-command" "flakes" ];
        flake-registry = lib.mkDefault "";
      };
    };
}
