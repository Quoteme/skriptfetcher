{
  description = "Modelltheorie-Skripte herunterladen und aktualisieren";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/080a4a27f206d07724b88da096e27ef63401a504";
  inputs.flake-utils = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShells.default = with pkgs; mkShell {
            buildInputs = [
              cmake
              curl
              git
              lean4
            ];
          };
        }
      );
}
