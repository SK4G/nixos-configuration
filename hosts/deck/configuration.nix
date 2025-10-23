# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    (import ./disko-config.nix {
      disks = [ "/dev/nvme0n1" ];
    })

    ./hardware-configuration.nix
    ./sdcard-automount.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;
  boot.consoleLogLevel = 1;
  boot.supportedFilesystems = [ "fuse" ];
  programs.fuse.userAllowOther = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # nodejs
    # python3
    # virtualenv
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.hostName = "steamdeck"; # Define your hostname.
  # networking.hostId = "05ee9e40"; # cut -c-8 </proc/sys/kernel/random/uuid

  networking.nameservers = [
    # "8.8.8.8"
    # "8.8.4.4"
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";
  services.fwupd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
