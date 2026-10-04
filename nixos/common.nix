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
    };

    # Point the registry and NIX_PATH at the flake inputs so `nix run nixpkgs#foo`
    # and `nix-shell -p foo` use the same nixpkgs as the system, without channels
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    channel.enable = false;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nixpkgs.overlays = [ (import ../home-manager/overlay.nix) ];
  nixpkgs.config.allowUnfree = true;
}
