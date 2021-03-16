{ config, lib, ... }:
with lib;
let
  cfg = config.caches;

  nixosCache = {
    url = "https://cache.nixos.org";
    key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
  };

  cachixCaches = map (import ./fetchCachix.nix) cfg.cachix;

  substituters = concatStringsSep " " (map (v: v.url) cfg.caches);
  publicKeys = concatStringsSep " " (concatMap (v: v.keys or [ v.key ]) cfg.caches);
  nixConfSource = ''
    substituters = ${substituters}
    trusted-public-keys = ${publicKeys}
  '';

in
{
  options.caches = {
    caches = mkOption {
      description = ''
        Caches to write to .config/nix/nix.conf.
        It is recommended you use `caches.cachix` and `caches.extraCaches` instead of setting this directly.
        If this value is set, the values of `caches.extraCaches` and `caches.cachix` will be ignored.
        The names are ignored.

        Example value:

          [
            {
              url = "https://cache.nixos.org";
              key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
            }
          ]

      '';
      type = with types; listOf attrs;
      default = cachixCaches ++ cfg.extraCaches ++ [ nixosCache ];
    };

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

  config.home.file.nixConf = {
    target = ".config/nix/nix.conf";
    text = nixConfSource;
  };
}
