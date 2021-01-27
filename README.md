# Declarative Cachix

Add [cachix](https://cachix.org/) caches declaratively.
You can use it either as a system module, or as a home-manager module.

### System module

Import `default.nix` into your system configuration.
This adds the top-level `cachix` option, which you can use to add cachix caches.
You can either pass them as names, or as `{name, sha256}` attribute pairs.

Example configuration:
```nix
  {
    imports = [
      (import (builtins.fetchTarball "https://github.com/jonascarpay/declarative-cachix/archive/2d37297b3aa1281193b1a3ca208c77467772cf5c.tar.gz"))
    ];

    cachix = [
      { name = "jmc"; sha256 = "1bk08lvxi41ppvry72y1b9fi7bb6qvsw6bn1ifzsn46s3j0idq0a"; }
      "iohk"
    ];
  }
```

### Home-manager module

#### Warning
Home-manager does not contain a mechanism for declaratively adding caches like the system config does.
This module adds that by generating a `.config/nix/nix.conf` file declaratively.
If you already have entries in that file, you need to move those to `home.file.nixConf.text` so they get included in the generated file.
If this file is malformed, it can break home-manager itself, so you then have to manually delete/fix it and fix your config.
I haven't had any issues myself, but caveat emptor.

#### Usage

Import `home-manager.nix` into your home-manager configuration.
This adds two user-facing options; `caches.extraCaches` and `caches.cachix`.
There's also `caches.caches`, but you typically don't want to set this manually since it also adds the normal nix hydra.

Example configuration:
```nix
  {
    imports = [
      (
        let
          declCachix = builtins.fetchTarball "https://github.com/jonascarpay/declarative-cachix/archive/2d37297b3aa1281193b1a3ca208c77467772cf5c.tar.gz";
        in import "${declCachix}/home-manager.nix"
      )
    ];

    caches.cachix = [
      { name = "jmc"; sha256 = "1bk08lvxi41ppvry72y1b9fi7bb6qvsw6bn1ifzsn46s3j0idq0a"; }
      "nix-community"
    ];

    caches.extraCaches = [
      {
        url = "https://hydra.iohk.io";
        key = "hydra.iohk.io:********************************************";
      }
    ];
  }
```
