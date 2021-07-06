{
  description = "Declarative cachix";

  outputs = _: {
    nixosModules.declarative-cachix = import ./default.nix;
    homeManagerModules.declarative-cachix = import ./home-manager.nix;
    homeManagerModules.declarative-cachix-experimental = import ./home-manager-experimental.nix;
  };
}
