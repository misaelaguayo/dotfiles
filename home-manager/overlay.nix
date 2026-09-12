(final: prev: {
  nix-search-tui = prev.callPackage
    (final.fetchFromGitHub {
      owner = "misaelaguayo";
      repo = "nix-search-tui";
      rev = "v0.2.0";
      hash = "sha256-Ksm9xZ0mFf5SVVzkHALnWCDT2aQl69IvWZgyR8dR1Mk=";
    })
    { };
  starship-jj = final.rustPlatform.buildRustPackage
    rec {
      pname = "starship-jj";
      version = "0.7.0";

      src = final.fetchFromGitLab {
        owner = "lanastara_foss";
        repo = "starship-jj";
        rev = "${version}";
        hash = "sha256-EgOKjPJK6NdHghMclbn4daywJ8oODiXkS48Nrn5cRZo=";
      };

      cargoHash = "sha256-NNeovW27YSK/fO2DjAsJqBvebd43usCw7ni47cgTth8=";
    };
    })

