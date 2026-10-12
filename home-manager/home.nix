{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };

    overlays = [ (import ./overlay.nix) ];
  };

  fonts.fontconfig.enable = true;

  # fixed rather than read from $USER/$HOME: flakes evaluate purely, where
  # getEnv always returns ""
  home.username = "misaelaguayo";
  home.homeDirectory = "/Users/misaelaguayo";

  xdg.configFile."ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/dotfiles/ghostty/config";

  home.packages = with pkgs; [
    nerd-fonts.hack
    docker
    docker-compose
    netcoredbg
    lldb
    deno
    cargo-generate
    lua-language-server
    git-credential-manager
    roslyn-ls
    imagemagick
    rustup
    claude-code
    mosh
    ghgrab
    yabai
    skhd
    firefox
  ];
}
