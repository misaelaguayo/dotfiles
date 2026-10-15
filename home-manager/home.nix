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
    fzf
    carapace
    claude-code
    lazyjj
    python3
    python314Packages.python-lsp-server
    (neovim.override {
      withPython3 = true;
      withRuby = false;

      extraPython3Packages = ps: with ps; [
        pynvim
      ];
    })
  ] ++ lib.optionals stdenv.isDarwin [
    yabai
    skhd
    firefox
  ];
}
