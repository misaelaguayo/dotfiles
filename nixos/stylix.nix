# Stylix for NixOS hosts; it also applies to their home-manager users.
# The scheme itself is chosen in ../theme.nix, shared with the Mac.
{ inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
    ../theme.nix
  ];
}
