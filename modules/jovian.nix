{ config, pkgs, lib, ... }:

let
  myUsername = "luiz";
  
in {
  imports = [
    ./desktop
    ./desktop/awesome.nix

  ];

  jovian = {
    devices.steamdeck = {
      enable = true;
      autoUpdate = true;
      enableOsFanControl = true;
      # enableGyroDsuService = true;
      # enableXorgRotation = true;
    };
    
    hardware = {
      amd.gpu.enableBacklightControl = true;
      amd.gpu.enableEarlyModesetting = true;
      has.amd.gpu = true; 
    };

    steam = {
      enable = true;
      # autoStart = true;
      # desktopSession = "none+awesome";
      desktopSession = "xfce+awesome";
      user = myUsername;
    };
    steamos = {
      useSteamOSConfig = true;
    };

    decky-loader = {
      enable = true;
      ### needed for powertools. use with nix-ld ?
      # extraPackages = [pkgs.pciutils];
      # extraPythonPackages = ;
      # user = myUsername;
    };
  };

  # show battery charge of bluetooth devices
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  # services.displayManager.sddm.enable = lib.mkIf config.jovian.steam.autoStart (lib.mkForce false);
  # boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernelPackages = pkgs.jovian-chaotic.linuxPackages_jovian;


  environment.systemPackages = with pkgs; [
    mangohud
    # galileo-mura
    # gamescope-session
    # linux_jovian
    powerbuttond
    # steam
    # steam_notif_daemon
    steamdeck-bios-fwupd
    steamdeck-dsp
    steamdeck-firmware
    steamdeck-hw-theme
    
    ### chaotic packages
    proton-ge-custom
    # jovian-chaotic.linux_jovian
    jovian-chaotic.mesa-radeonsi-jupiter
    jovian-chaotic.mesa-radv-jupiter
  ];
}
