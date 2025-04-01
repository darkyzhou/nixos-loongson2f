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
    in
    {
      nixosConfigurations.sakimi_8089 = mkSystem [ ./configs/8089.nix ];
      nixosConfigurations.sakimi_9001 = mkSystem [ ];

      packages.x86_64-linux.image_8089 = self.nixosConfigurations.sakimi_8089.config.system.build.image;
      packages.x86_64-linux.image_9001 = self.nixosConfigurations.sakimi_9001.config.system.build.image;
    };
}
