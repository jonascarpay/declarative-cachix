{ config, lib, options, ... }:
with lib;
let

  cachices = map (import ./fetchCachix.nix) config.cachix;
  urls = map (c: c.url) cachices;
  keys = concatMap (c: c.keys) cachices;

in
{

  options.cachix = mkOption {
    type = with types; listOf (either str attrs);
    default = [ ];
    description = ''
      Accepts two configuration formats; either as a string, or an attribute
      set with a specified sha (recommended).
      Example value:

      [
        "someCachix"
        "someOtherCachix"
        { name = "someCachixWithSha"; sha256 = "..."; }
      ]
    '';
  };

  config =
    if options.nix ? settings then
      {
        nix.settings.substituters = urls;
        nix.settings.trusted-public-keys = keys;
      }
    else
      {
        nix.binaryCaches = urls;
        nix.binaryCachePublicKeys = keys;
      };

}
