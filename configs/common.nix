{
  config,
  pkgs,
  lib,
  bootPartitionLabel,
  rootPartitionLabel,
  ...
}:
{
  system.stateVersion = "25.05";

  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

  boot.postBootCommands =
    ''
      if [ -f /nix-path-registration ]; then
        ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration && rm /nix-path-registration
      fi
    ''
    + ''
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
    '';

  boot = {
    loader.external = {
      enable = true;
      installHook = "${lib.getExe pkgs.pmon-boot-cfg} ${builtins.storeDir} /boot '(wd0,0)'";
    };

    kernelPackages = pkgs.linuxPackages_lemote2f;
  };

  system.boot.loader.kernelFile = lib.mkForce "vmlinuz-${config.boot.kernelPackages.kernel.modDirVersion}";

  system.requiredKernelConfig = lib.mkForce [ ];

  # https://github.com/NixOS/nixpkgs/pull/330296
  systemd.suppressedSystemUnits = [
    "systemd-pcrlock@.service"
    "systemd-pcrlock.socket"
    "systemd-hibernate-clear.service"
    "systemd-bootctl@.service"
    "systemd-bootctl.socket"
  ];

  system.switch.enableNg = false;

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/${bootPartitionLabel}";
    options = [ "noatime" ];
    fsType = "ext2";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/${rootPartitionLabel}";
    options = [ "noatime" ];
    fsType = "ext4";
  };

  networking.hostName = "sakimi";

  documentation.nixos.enable = false;
  security.polkit.enable = false;
  services.udisks2.enable = false;
  systemd.shutdownRamfs.enable = false;
  services.nscd.enableNsncd = false;
  programs.less.lessopen = null;
  services.timesyncd.enable = false;
  systemd.services.audit.enable = false; # No audit on MIPS
  networking.firewall.logRefusedConnections = false;

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  users = {
    mutableUsers = false;
    users.root.initialPassword = "114514";
  };

  services.journald.extraConfig = ''
    Storage=volatile
  '';

  environment.systemPackages = with pkgs; [
    jq
    lm_sensors
    pciutils
    wpa_supplicant
    gcc
    binutils
    curl
    htop
    pfetch
    txiki
  ];
}
