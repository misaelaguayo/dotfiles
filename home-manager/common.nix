{ pkgs, lib, ... }:

{
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    ripgrep
    git
    nix-output-monitor
    jujutsu
    nodejs_24
    nix-search-cli
    zellij
    zoxide
    mergiraf
    delta
    difftastic
    starship
    starship-jj
    pandoc
    fzf
    carapace
    (neovim.override {
      withPython3 = true;
      withRuby = false;
      extraPython3Packages = ps: with ps; [ pynvim ];
    })
  ];

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;

    nushell.enable = true;

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
  };
}
