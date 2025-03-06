{
  description = "ports for the evergarden theme";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    evergarden-whiskers.url = "github:everviolet/whiskers";
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      forAllSystems =
        function: lib.genAttrs lib.systems.flakeExposed (system: function nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.callPackage ./shell.nix {
          evergarden-whiskers =
            inputs.evergarden-whiskers.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      });
    };
}
