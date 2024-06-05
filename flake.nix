{
  description = "Rstatus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    crane,
    flake-utils,
    ...
  }:
    {
      overlays.default = _: prev: {
        rstatus = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
      overlays.rstatus = self.overlays.default;
      nixosModules.default = import ./rstatus.nix inputs;
      nixosModules.rstatus = self.nixosModules.default;
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      craneLib = crane.mkLib pkgs;

      commonArgs = {
        src = craneLib.cleanCargoSource (craneLib.path ./.);
        strictDeps = true;
      };

      rstatus = craneLib.buildPackage (commonArgs
        // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        });
    in {
      checks = {
        inherit rstatus;
      };

      formatter = pkgs.alejandra;

      packages.default = rstatus;
      packages.rstatus = rstatus;

      apps.default = flake-utils.lib.mkApp {
        drv = rstatus;
      };

      devShells.default = craneLib.devShell {
        checks = self.checks.${system};

        packages = with pkgs; [
          rust-analyzer
          taplo
        ];
      };
    }));
}
