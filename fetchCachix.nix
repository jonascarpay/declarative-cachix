# Takes either a name or a {name : string, sha256 : string} attribute set,
# and returns a {name : string, keys : [string]} pair
let

  getCache = args:
    let
      content = builtins.fetchurl ({
        url = "https://cachix.org/api/v1/cache/${args.name}";
      } // optionalAttrs (args ? sha256) { inherit (args) sha256; });
      json = builtins.fromJSON (builtins.readFile content);
      url = json.uri;
      keys = json.publicSigningKeys;
    in
    { inherit url keys; };
in
arg: if isString arg then getCache { name = arg; } else getCache arg
