{
  description = "ikhlasulov-pr";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";

    overlays = [
      (final: prev: {
        llama-cpp = prev.llama-cpp.overrideAttrs (old: {
          NIX_CFLAGS_COMPILE =
            (old.NIX_CFLAGS_COMPILE or "") + " -O2 -march=native";
          NIX_CXXFLAGS_COMPILE =
            (old.NIX_CXXFLAGS_COMPILE or "") + " -O2 -march=native";
          buildInputs = (old.buildInputs or []) ++ [ prev.gcc ];
        });
      })
    ];
  in {
    nixosConfigurations.ikhlasulov-pr =
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ({ ... }: {
            nixpkgs = {
              inherit overlays;
              config.allowUnfree = true;
            };
          })

          ./configuration.nix
        ];
      };
  };
}
