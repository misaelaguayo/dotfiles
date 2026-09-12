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

    nushell = {
      enable = true;
      configFile.source = ../nushell/config.nu;
      envFile.source = ../nushell/env.nu;
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    starship = {
      enable = true;
      # nushell/config.nu already handles init via vendor/autoload
      enableNushellIntegration = false;
      extraPackages = [ pkgs.starship-jj ];
      settings = {
        custom.jj = {
          command = "prompt";
          format = "$output";
          ignore_timeout = true;
          shell = [ "starship-jj" "--ignore-working-copy" "starship" ];
          use_stdin = false;
          when = true;
        };
      };
    };
  };
}
