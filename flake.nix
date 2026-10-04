{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/common.nix
          hostPath
        ];
      };
    in
    {
      # Attribute names match networking.hostName so `nixos-rebuild switch --flake .` picks the right one
      nixosConfigurations = {
        missileserv = mkHost ./nixos/hosts/server/configuration.nix;
        nixos = mkHost ./nixos/hosts/desktop/configuration.nix;
      };
    };
}
