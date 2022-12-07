{ config, lib, ... }:
with lib;
let
  cfg = config.caches;

  caches =
    let toCachix = import ./fetchCachix.nix;
    in map toCachix cfg.cachix ++ cfg.extraCaches;

  substituters = concatStringsSep " " (map (v: v.url) caches);
  publicKeys = concatStringsSep " " (concatMap (v: v.keys or [ v.key ]) caches);

  nixSettings = {
    extra-substituters = substituters;
    extra-trusted-public-keys = publicKeys;
  };

in
{
  options.caches = {
    extraCaches = mkOption {
      description = ''
        Caches to append to .config/nix/nix.conf.
        The names are ignored.
        Same as caches.caches, but composes with caches.cachix and leaves the
        default nixos cache intact.

        Example value:

          [
            {
              url = "https://hydra.iohk.io";
              key = "hydra.iohk.io:********************************************";
            }
          ]
      '';
      type = with types; listOf attrs;
      default = [ ];
    };

    cachix = mkOption {
      description = ''
        Cachix caches to append to .config/nix/nix.conf.
        Accepts two configuration formats; either as a string, or an attribute
        set with a specified sha (recommended).

        Example value:

        [
          "someCachix"
          "someOtherCachix"
          { name = "someCachixWithSha"; sha256 = "..."; }
        ]
      '';
      default = [ ];
      type = with types; listOf (either string attrs);
    };
  };

  config.nix.settings = nixSettings;
}
