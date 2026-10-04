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
      settings = {
        format = lib.concatStrings [
          "$username$hostname$localip$shlvl$singularity$kubernetes$nats"
          "$directory$vcsh$vcs"
          "$docker_context$package$bun$c$cmake$cobol$cpp$daml$dart$deno$dotnet"
          "$elixir$elm$erlang$fennel$fortran$gleam$golang$gradle$haskell$haxe"
          "$helm$java$julia$kotlin$lua$maven$mojo$nim$nodejs$ocaml$odin$opa"
          "$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust"
          "$scala$solidity$swift$terraform$typst$vlang$vagrant$xmake$zig$buf"
          "$guix_shell$nix_shell$conda$pixi$meson$spack$memory_usage"
          "$aws$gcloud$openstack$azure$direnv$env_var$mise$crystal$custom"
          "$sudo$cmd_duration$line_break$jobs$battery$time$status$container"
          "$netns$os$shell$character"
        ];
        vcs.order = [ "jj" "git" "hg" "pijul" "fossil" ];
      };
    };
  };
}
