{ config, pkgs, lib, ... }:

let
  # Out-of-store links point straight at the checkout, so edits to these
  # configs take effect immediately without a rebuild.
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.stateVersion = "23.11";

  xdg.configFile = {
    "nvim".source = link "nvim";
    "jj/config.toml".source = link "jj/config.toml";
    "zellij/config.kdl".source = link "zellij/config.kdl";
  };

  home.packages = with pkgs; [
    ripgrep
    git
    nix-output-monitor
    jujutsu
    nodejs_24
    nix-search-cli
    zellij
    mergiraf
    difftastic
    pandoc
    fzf
    fd
    nixd
    nixfmt
    nh
    jjui
    lazyjj
    tree-sitter # nvim-treesitter (main) compiles parsers with it
    gcc
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

    git.enable = true;

    # Unified diffs with syntax highlighting and line numbers; n/N jump
    # between files in the pager
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };

    zoxide.enable = true;

    # a program module rather than a bare package so Stylix can theme it
    bat.enable = true;

    # searchable shell history; `atuin login` once per machine to sync
    atuin.enable = true;

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
