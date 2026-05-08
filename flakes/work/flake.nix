{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        dotnet-sdk-custom = pkgs.stdenv.mkDerivation rec {
          pname = "dotnet-sdk";
          version = "10.0.203";

          src = pkgs.fetchurl {
            url = "https://builds.dotnet.microsoft.com/dotnet/Sdk/${version}/dotnet-sdk-${version}-osx-arm64.tar.gz";
            hash = "sha256-y/HFBm/yCDpvIb0bKq7mxRVn0ITi8d2Q381VhUEUTyA=";
          };

          # Nix expects one folder after unpacking. Tell nix not to cd
          sourceRoot = ".";

          # Skip build phase since our tarball has the binary already
          dontBuild = true;

          # Need share directory since tarball has multiple directories
          installPhase = ''
            mkdir -p $out/share/dotnet
            cp -r . $out/share/dotnet

            mkdir -p $out/bin
            ln -s $out/share/dotnet/dotnet $out/bin/dotnet
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            dotnet-sdk-custom
            tailwindcss-language-server
            roslyn-ls
            postgresql
            powershell
            protobuf
            ngrok
            azure-cli
          ];

          DOTNET_ROOT = "${dotnet-sdk-custom}/share/dotnet";
          DOTNET_CLI_TELEMETRY_OPTOUT = "1";
          DOTNET_NOLOGO = "1";
        };
      }
    );
}
