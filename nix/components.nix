# First-party source is always taken from this checkout, Aizome's with
# Sekka's `sidestep` input, and the catalog's applications from other flakes
# from Sekka's own inputs of those names.
{
  nixpkgs,
  sidestep,
  superluminal,
  tracy,
}:
let
  # PCs, and Apple Silicon Macs (nix/apple-silicon).
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  forSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
in
rec {
  aizome = import ../desktop/aizome/nix { inherit nixpkgs sidestep; };
  tatami = {
    outPath = ../desktop/tatami;
    nixosModules.default = ../desktop/tatami/module.nix;
    packages = forSystems (pkgs: {
      tatami = pkgs.callPackage ../desktop/tatami/tool/package.nix { };
      displays = pkgs.callPackage ../desktop/tatami/displays/package.nix { };
      network = pkgs.callPackage ../desktop/tatami/network/package.nix { };
      bluetooth = pkgs.callPackage ../desktop/tatami/bluetooth/package.nix { };
      sound = pkgs.callPackage ../desktop/tatami/sound/package.nix { };
      activity = pkgs.callPackage ../desktop/tatami/activity/package.nix { };
      wallpapers = pkgs.callPackage ../desktop/tatami/wallpapers/package.nix { };
      elephant = pkgs.callPackage ../desktop/tatami/elephant/package.nix { };
    });
  };
  yukimi = {
    outPath = ../apps/yukimi;
    nixosModules.default = import ../apps/yukimi/nix/module.nix yukimi;
    packages = forSystems (pkgs: {
      yukimi = pkgs.callPackage ../apps/yukimi/nix/package.nix { };
    });
  };
  kakehashi = {
    outPath = ../apps/kakehashi;
    packages = forSystems (pkgs: {
      kakehashi = (import ./kakehashi.nix { inherit pkgs; }).package;
    });
  };
  # The catalog's applications from this flake (source "sekka"): its own, and
  # those other flakes package, built with the applications' Nixpkgs.
  catalog.packages = forSystems (pkgs:
    let system = pkgs.stdenv.hostPlatform.system;
    in kakehashi.packages.${system} // {
      superluminal = superluminal.packages.${system}.default;
      tracy = tracy.packages.${system}.tracy;
    });
  calamares = {
    outPath = ../installer/genkan;
    nixosModules = {
      default.imports = [
        calamares.nixosModules.desktops
        calamares.nixosModules.applications
      ];
      desktops.imports = [
        ../installer/genkan/rust/system
        tatami.nixosModules.default
        yukimi.nixosModules.default
        aizome.nixosModules.default
      ];
      applications = { pkgs, ... }: {
        key = "sekka#applications";
        imports = [ ../installer/genkan/rust/src/applications.nix ];
        _module.args.sekkaPackages = catalog.packages.${pkgs.stdenv.hostPlatform.system};
      };
    };
  };
}
