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
    ./stylix.nix
  ];

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes" ];

      nix-path = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    channel.enable = false;

    gc.automatic = true;
  };

  # Expire stale GC roots (result links, .direnv, old profile generations)
  services.angrr = {
    enable = true;
    period = "7d";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";

  nixpkgs.overlays = [ (import ../home-manager/overlay.nix) ];
  nixpkgs.config.allowUnfree = true;
}
