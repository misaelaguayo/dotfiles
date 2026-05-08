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
  ];

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;

    nushell = {
      enable = true;
      package = pkgs.nushell.overrideAttrs (oldAttrs: {
        # temporary workaround. tests failing
        doCheck = false;
        doInstallCheck = false;
      });
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
  };
}
