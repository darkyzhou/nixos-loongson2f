{ ... }:
let
  kernelVersion = "6.6.25";
in
{
  allow-modules-missing = self: super: {
    makeModulesClosure =
      {
        kernel,
        firmware,
        rootModules,
        allowMissing ? true,
        extraFirmwarePaths,
      }:
      super.callPackage "${super.path}/pkgs/build-support/kernel/modules-closure.nix" {
        inherit
          kernel
          firmware
          rootModules
          extraFirmwarePaths
          ;
        allowMissing = true;
      };
  };

  main = final: prev: {
    linux_lemote2f = final.linuxManualConfig {
      modDirVersion = kernelVersion;
      src = final.fetchurl {
        url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${kernelVersion}.tar.xz";
        hash = "sha256-mdIQvoeQgjOlWw+twNzNO5WSbAZRtrguNzULICneH0Q=";
      };
      # https://github.com/NixOS/nixpkgs/pull/302802
      config = final.read-linux-config ./lemote2f_config;
      version = "${final.linux.version}-lemote2f";
      configfile = ./lemote2f_config;
      kernelPatches = [
        {
          name = "ec_kb3310b";
          patch = (
            final.fetchpatch {
              url = "https://github.com/loongson-community/linux-2f/commit/08fda2d6be96684e4753e89fa54c33bb4553f621.patch";
              hash = "sha256-CRKovOD/tDNptUSPhDnpp8INH6zXIoPmfU29PNYapA8=";
            }
          );
        }
        {
          name = "yeeloong_laptop";
          patch = (
            final.fetchpatch {
              url = "https://github.com/loongson-community/linux-2f/commit/ad2584dbce931975c4a1219bf4ac8099aaf636c2.patch";
              hash = "sha256-GB8l1e5Yb3WIuiiiXorBsEKdDAjQdH7kvepkF+Rbjr8=";
            }
          );
        }
      ];
    };

    linuxPackages_lemote2f = final.linuxPackagesFor final.linux_lemote2f;

    read-linux-config = final.callPackage ./read-linux-config.nix { };

    # FIXME: libressl doesn't work on MIPS?
    netcat = final.netcat-gnu;

    # https://github.com/NixOS/nixpkgs/pull/298001
    gnupg24 = prev.gnupg24.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ final.buildPackages.libgpg-error ];
    });

    # https://github.com/NixOS/nixpkgs/pull/379618#issuecomment-2676056813
    pcre2 =
      let
        version = "10.45";
      in
      prev.pcre2.overrideAttrs (old: {
        inherit version;
        src = final.fetchurl {
          url = "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-${version}/pcre2-${version}.tar.bz2";
          hash = "sha256-IVR/NRYSDHVZflswqZLielkqMZULUUDnuL/ePxkgM8Q=";
        };
      });

    # Workaround strange compliation errors with gobject-introspection
    glib = prev.glib.override (_: {
      withIntrospection = false;
    });
    gdk-pixbuf = prev.gdk-pixbuf.override (_: {
      withIntrospection = false;
    });
    json-glib = prev.json-glib.override (_: {
      withIntrospection = false;
    });
    harfbuzz = prev.harfbuzz.override (_: {
      withIntrospection = false;
    });
    pango = prev.pango.override (_: {
      withIntrospection = false;
    });

    openssh =
      if final.hostPlatform.isMips then
        prev.openssh.overrideAttrs (old: {
          configureFlags = old.configureFlags ++ [ "--without-hardening" ];
        })
      else
        prev.openssh;

    pmon-boot-cfg = final.callPackage ../packages/pmon-boot-cfg { };

    txiki = final.callPackage ../packages/txiki { };
  };
}
