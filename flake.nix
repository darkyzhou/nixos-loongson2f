{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      legacyPackages = import ./pkgs.nix { inherit nixpkgs; };
      mkSystem =
        modules:
        nixpkgs.lib.nixosSystem {
          system = "mips64el-linux";
          modules = [
            { nixpkgs.pkgs = legacyPackages."x86_64-linux"; }
            ./packages/build-image
            ./configs/common.nix
          ] ++ modules;
          specialArgs = {
            bootPartitionLabel = "sakimi-boot";
            rootPartitionLabel = "sakimi-nixos";
          };
        };
      mk8089 = extraModules: mkSystem [ ./configs/8089.nix ] ++ extraModules;
      mk9001 = extraModules: mkSystem extraModules;
    in
    {
      lib = { inherit mk8089 mk9001; };

      nixosConfigurations.sakimi_8089 = mk8089 [ ];
      nixosConfigurations.sakimi_9001 = mk9001 [ ];

      packages.x86_64-linux.image_8089 = self.nixosConfigurations.sakimi_8089.config.system.build.image;
      packages.x86_64-linux.image_9001 = self.nixosConfigurations.sakimi_9001.config.system.build.image;
    };
}
