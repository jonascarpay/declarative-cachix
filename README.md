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
      (import (builtins.fetchTarball "https://github.com/jonascarpay/declarative-cachix/archive/a2aead56e21e81e3eda1dc58ac2d5e1dc4bf05d7.tar.gz"))
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
This module implements that mechanism itself by generating a `.config/nix/nix.conf` file declaratively.

This has two important implications:
  1. If you already have entries in that file aside from the default nix cache, you need to move those to `home.file.nixConf.text` so they get included in the generated file.
  2. If the file is somehow malformed, it will break home-manager itself, so you then have to manually delete it and fix your config. I haven't had any issues myself, but caveat emptor.

#### Usage

Import `home-manager.nix` into your home-manager configuration.
This adds two user-facing options; `caches.extraCaches` and `caches.cachix`.

Note that you need to be a trusted user to be able to specify caches.
See [this issue](https://github.com/jonascarpay/declarative-cachix/issues/2) for more information.

Example configuration:
```nix
  {
    imports = [
      (
        let
          declCachix = builtins.fetchTarball "https://github.com/jonascarpay/declarative-cachix/archive/a2aead56e21e81e3eda1dc58ac2d5e1dc4bf05d7.tar.gz";
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

#### Experimental

There is a `home-manager-experimental.nix` module that uses the `extra-substituters` and `extra-trusted-public-keys` configuration fields, instead of the normal `substituters` and `trusted-public-keys`.
These fields compose better and have less risk of accidentally overriding other configuration, but unfortunately they are not yet available in stable nix.

If you're on unstable and have enabled experimental features, and you're having issues where your caches are not properly being picked up, consider switching to this module.
It takes the same options as the normal module.
