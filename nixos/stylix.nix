{ inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
    ../theme.nix
  ];
}
