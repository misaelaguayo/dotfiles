{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./common.nix ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  fonts.fontconfig.enable = true;

  home.sessionVariables.CLAUDE_CODE_CERT_STORE = "bundled,system";

  xdg.configFile."ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/dotfiles/ghostty/config";

  # Standalone home-manager can't set the login shell on macOS, so warn until it's fish
  home.activation.checkLoginShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    loginShell=$(/usr/bin/dscl . -read "/Users/$USER" UserShell | /usr/bin/awk '{print $2}')
    if [ "$(basename "$loginShell")" != fish ]; then
      fishPath="${config.home.profileDirectory}/bin/fish"
      warnEcho "Login shell is $loginShell, not fish. To fix:"
      warnEcho "  grep -qx $fishPath /etc/shells || echo $fishPath | sudo tee -a /etc/shells"
      warnEcho "  chsh -s $fishPath"
    fi
  '';

  home.packages =
    with pkgs;
    [
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
      minikube
      python314Packages.python-lsp-server
      (neovim.override {
        withPython3 = true;
        withRuby = false;

        extraPython3Packages =
          ps: with ps; [
            pynvim
          ];
      })
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      yabai
      skhd
      firefox
    ];
}
