{
  description = "ikhlasulov-pr";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }:
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

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.sharedModules = [
                plasma-manager.homeModules.plasma-manager
              ];

              home-manager.users.ikhlasulov = import ./home.nix;
              home-manager.users.ikhlasulov-dt = import ./home.nix;
            }
          ];
        };
    };
}
