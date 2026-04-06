{ pkgs, lib, ... }:

{
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

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    ripgrep
    nushell
    nerd-fonts.hack
    git
    docker
    nix-output-monitor
    jujutsu
    nodejs_24
    docker-compose
    netcoredbg
    lldb
    deno
    cargo-generate
    nix-search-cli
    lua-language-server
    neovim
    zellij
    # nix-search-tui
    zoxide
    mergiraf
    delta
    git-credential-manager
    roslyn-ls
    difftastic
    starship
    starship-jj
    pandoc
    imagemagick
    rustup
    fzf
    carapace
  ] ++ lib.optionals stdenv.isDarwin [
    yabai
    skhd
  ];

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;
    nushell.enable = true;
  };

}
