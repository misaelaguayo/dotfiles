# Shared base configuration imported by every host in flake.nix.

{ inputs
, lib
, ...
}:
let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes" ];

      nix-path = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    channel.enable = false;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nixpkgs.overlays = [ (import ../home-manager/overlay.nix) ];
  nixpkgs.config.allowUnfree = true;
}
