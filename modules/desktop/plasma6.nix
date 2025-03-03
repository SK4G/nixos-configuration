{ config, pkgs, ... }:
{
  # Network configuration and management tool
  networking.networkmanager.enable = true;

  # Enable the Plasma 6 Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # KDE complains if power management is disabled (to be precise, if
  # there is no power management backend such as upower)
  powerManagement.enable = true;
}
