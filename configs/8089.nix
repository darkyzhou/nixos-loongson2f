{ ... }:
{
  services.gpm.enable = true;

  networking.supplicant.wlp0s14f5u4 = {
    configFile.path = "/var/wpa_supplicant.conf";
    configFile.writable = true;
    userControlled.enable = true;
  };
}
