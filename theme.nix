# The one place the color scheme and font are chosen. Imported by every
# machine: NixOS hosts through nixos/stylix.nix, the Mac through its
# home-manager config in flake.nix. Stylix themes every program it has a
# target for, and also writes ~/.config/stylix/palette.json, which nvim reads
# (nvim/lua/config/theme.lua). The option names are the same in Stylix's NixOS
# and home-manager modules, so this file works in both.
{ pkgs, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    fonts.monospace = {
      package = pkgs.nerd-fonts.hack;
      name = "Hack Nerd Font";
    };
  };
}
