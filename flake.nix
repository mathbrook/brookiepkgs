{
  description = "my packages. im tired of making new repos for nix packages and im too lazy to push em up to nixpkgs";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    nix-proto.url = "github:notalltim/nix-proto";
    nebs-packages.url = "github:RCMast3r/nebs_packages";
  };
  outputs = { self, nixpkgs, flake-parts, devshell, nebs-packages, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.devshell.flakeModule
        ];
        perSystem = { config, pkgs, system, ... }:
          let
            foxglove-studio = pkgs.callPackage ./foxglove-studio.nix { inherit system; };
          in
          {
            packages.foxglove-studio = foxglove-studio;
            overlayAttrs = {
              inherit (config.packages) default foxglove-studio;
            };
            legacyPackages =
              import nixpkgs {
                inherit system;
                overlays = [ self.overlays.default ];
              };
          };
      };
}