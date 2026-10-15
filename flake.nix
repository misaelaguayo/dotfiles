{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent.url = "github:NousResearch/hermes-agent/v2026.9.24";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      stylix,
      ...
    }@inputs:
    let
      mkHost =
        hostPath:
        nixpkgs.lib.nixosSystem {
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

      # Macs have no NixOS, just standalone home-manager:
      #   home-manager switch --flake .#misaelaguayo
      #   home-manager switch --flake .#misael
      homeConfigurations =
        let
          mkMac =
            username:
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.aarch64-darwin;
              modules = [
                stylix.homeModules.stylix
                ./theme.nix
                ./home-manager/home.nix
                {
                  home.username = username;
                  home.homeDirectory = "/Users/${username}";
                }
              ];
            };
        in
        {
          misaelaguayo = mkMac "misaelaguayo";
          misael = mkMac "misael";
        };
    };
}
