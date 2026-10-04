(final: prev: {
  nix-search-tui = prev.callPackage
    (final.fetchFromGitHub {
      owner = "misaelaguayo";
      repo = "nix-search-tui";
      rev = "v0.2.0";
      hash = "sha256-Ksm9xZ0mFf5SVVzkHALnWCDT2aQl69IvWZgyR8dR1Mk=";
    })
    { };
  starship =
    if final.lib.versionAtLeast prev.starship.version "1.27.0" then
      final.lib.warn
        "home-manager/overlay.nix: nixpkgs now has starship ${prev.starship.version} with native jj support; the starship override can be removed"
        prev.starship
    else
      prev.starship.overrideAttrs (finalAttrs: old: {
        version = "1.26.0-unstable-2026-09-27";

        src = final.fetchFromGitHub {
          owner = "starship";
          repo = "starship";
          rev = "131bf9552d7e927607e155ea3a9b8c8a170a0356";
          hash = "sha256-H85gbkcFiGIOAx11F2/U+V2WxkDKhIF1qcasvnxN8L8=";
        };

        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit (finalAttrs) src;
          name = "${finalAttrs.pname}-${finalAttrs.version}";
          hash = "sha256-g06GmHmTC5X6R/YgIvKcwnN//fvLwh3hhnOAFhWnMwA=";
        };
      });
})

