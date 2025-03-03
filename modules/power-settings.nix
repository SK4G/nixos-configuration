{ config, pkgs, lib, ... }:

{
  powerManagement.cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);
    
  services.tlp.enable = lib.mkDefault true;
  services.tlp.settings = {
    DISK_DEVICES = "nvme0n1";

    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    START_CHARGE_THRESH_BAT0 = 60;
    STOP_CHARGE_THRESH_BAT0 = 80;
    
    HandlePowerKey = "suspend";
  };

}