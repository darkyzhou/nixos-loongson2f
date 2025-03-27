{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    {
      legacyPackages = import ./pkgs.nix { inherit nixpkgs; };

      nixosConfigurations.sakimi = nixpkgs.lib.nixosSystem {
        system = "mips64el-linux";
        modules = [
          { nixpkgs.pkgs = self.legacyPackages."x86_64-linux"; }
          ./configuration.nix
          ./packages/build-image
        ];
        specialArgs = {
          bootPartitionLabel = "sakimi-boot";
          rootPartitionLabel = "sakimi-nixos";
        };
      };

      packages.x86_64-linux.image = self.nixosConfigurations.sakimi.config.system.build.image;
    };
}
