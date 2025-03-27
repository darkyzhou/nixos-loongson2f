{ nixpkgs }:
let
  hostSystem = "x86_64-linux";
  eachSystem = nixpkgs.lib.genAttrs [ hostSystem ];
  overlays = import ./overlays { inherit nixpkgs hostSystem; };
in
eachSystem (
  system:
  import nixpkgs {
    inherit system;

    overlays = [
      overlays.main
      overlays.allow-modules-missing
    ];

    crossSystem = {
      config = "mips64el-unknown-linux-gnuabi64";

      linux-kernel = {
        name = "lemote2f";
        target = "vmlinuz";
        baseConfig = "lemote2f_defconfig";
        autoModules = false;
      };

      gcc = {
        arch = "loongson2f";
        float = "hard";
        abi = "64";
      };

      emulator =
        pkgs:
        let
          mips64el = pkgs.lib.systems.elaborate pkgs.lib.systems.examples.mips64el-linux-gnuabi64;
          qemu-user = mips64el.emulator pkgs;
          qemu-user-wrapped = pkgs.writeShellScriptBin "qemu-mips64el-loongson2f" ''
            exec "${qemu-user}" -cpu Loongson-2F "$@"
          '';
        in
        "${qemu-user-wrapped}/bin/qemu-mips64el-loongson2f";
    };
  }
)
