{ config, lib, ... }:
with lib;
let

  cachices = map (import ./fetchCachix.nix) config.cachix;

in
{

  options.cachix = mkOption {
    type = with types; listOf (either str attrs);
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

  config = {
    nix.binaryCaches = map (c: c.url) cachices;
    nix.binaryCachePublicKeys = concatMap (c: c.keys) cachices;
  };

}
