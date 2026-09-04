{ pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ./wayland.nix
  ];

  home.username = "misael";
  home.homeDirectory = "/home/misael";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.hack
    git-credential-manager
    roslyn-ls
    netcoredbg
    lldb
    lua-language-server
    deno
    cargo-generate
    imagemagick
    rustup
  ];
}
