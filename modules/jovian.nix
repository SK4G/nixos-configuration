{ config, pkgs, lib, host ? null, ... }:

let
  myUsername = "luiz";
  
in {
  imports = [
    ./desktop
    ./desktop/awesome.nix
  ];

  jovian = {
    devices.steamdeck = lib.mkIf (host == "deck") {
      enable = true;
      autoUpdate = true;
      enableOsFanControl = true;
      # enableGyroDsuService = true;
      # enableXorgRotation = true;
    };
    
    hardware = lib.mkIf (host == "deck") {
      amd.gpu.enableBacklightControl = true;
      amd.gpu.enableEarlyModesetting = true;
      has.amd.gpu = true; 
    };

    steam = {
      enable = true;
      # autoStart = true;
      # desktopSession = "xfce+awesome";
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
  # Default kernel
  # boot.kernelPackages = pkgs.jovian-chaotic.linuxPackages_jovian;
  # Specialisation for DaVinci Resolve working kernel
  # specialisation.davinci-resolve.configuration = {
  #   boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;
  # };

  environment.systemPackages = with pkgs; [
    mangohud
    # mesa-radeonsi-jupiter
    powerbuttond
    steamdeck-bios-fwupd
    steamdeck-dsp
    steamdeck-firmware
    steamdeck-hw-theme
    mesa-radeonsi-jupiter
  ]; 
  # Prevent the upstream jupiter controller updater service from starting
  # during rebuilds (it fails enumerating devices on this system).
  # systemd = {
  #   services."jupiter-controller-update" = {
  #     enable = lib.mkIf (host == "deck") (lib.mkForce false);
  #   };
  # };
  # ++ (with jovian-chaotic; [
  #   mangohud
  #   proton-ge-custom
  #   # mesa-radeonsi-jupiter
  #   powerbuttond
  #   steamdeck-bios-fwupd
  #   steamdeck-dsp
  #   steamdeck-firmware
  #   steamdeck-hw-theme
  #   mesa-radeonsi-jupiter
  # ]);
}