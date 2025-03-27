{
  pkgs,
  config,
  modulesPath,
  bootPartitionLabel,
  rootPartitionLabel,
  ...
}:
{
  system.build.image =
    let
      storeDir = builtins.storeDir;
      topLevel = config.system.build.toplevel;
      bootSizeMiB = 200;
      rootSizeMiB = 6000;
      bootLabel = bootPartitionLabel;
      rootLabel = rootPartitionLabel;
      rootImage = pkgs.callPackage "${toString modulesPath}/../lib/make-ext4-fs.nix" {
        storePaths = [ topLevel ];
        volumeLabel = rootLabel;
      };
      outputImage = "nixos-loongson-2f.img";
    in
    pkgs.stdenv.mkDerivation {
      name = outputImage;
      builder = ./build-image.sh;

      nativeBuildInputs = with pkgs; [
        pmon-boot-cfg
        util-linux
        genext2fs
      ];

      inherit
        storeDir
        topLevel
        rootImage
        bootSizeMiB
        rootSizeMiB
        bootLabel
        outputImage
        ;
    };
}
