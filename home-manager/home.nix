{ pkgs, lib, ... }:

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

  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

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
  ];

  programs = {
    nushell = {
      package = pkgs.nushell.overrideAttrs (oldAttrs: {
        # temporary workaround. tests failing
        doCheck = false;
        doInstallCheck = false;
      });

      # mac's ~/.config/nushell is a manual symlink into this checkout,
      # not home-manager managed like it is on the NixOS hosts.
      configFile = lib.mkForce null;
      envFile = lib.mkForce null;
    };
  };
}
