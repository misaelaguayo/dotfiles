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
    mergiraf
    delta
    difftastic
    pandoc
    fzf
    (neovim.override {
      withPython3 = true;
      withRuby = false;
      extraPython3Packages = ps: with ps; [ pynvim ];
    })
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;

    zoxide.enable = true;

    carapace.enable = true;

    fish = {
      enable = true;
      shellInit = ''
        fish_add_path --prepend --move "$HOME/.nix-profile/bin"
        fish_add_path --prepend --move "/nix/var/nix/profiles/default/bin"
      '';
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    starship = {
      enable = true;
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
