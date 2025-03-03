{ config, pkgs, ... }:

{
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  
  environment.systemPackages = with pkgs; [    
    lxappearance
    xfce.xfce4-appfinder
    xfce.xfce4-battery-plugin
    xfce.xfce4-clipman-plugin
    # xfce.xfce4-netload-plugin
    xfce.xfce4-power-manager
    xfce.xfce4-screenshooter
    # xfce.xfce4-sensors-plugin
    xfce.xfce4-settings
    xfce.xfce4-taskmanager
    xfce.xfce4-xkb-plugin
    # xfce.xfce4-weather-plugin

    xfce.catfish
    xfce.exo
    xfce.garcon
    xfce.mousepad
    xfce.ristretto
    #xfce.thunar
    #xfce.thunar-archive-plugin
    #xfce.thunar-volman
    xfce.tumbler
    xfce.xfconf
    # xfce.xfwm4
];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  powerManagement.enable = true;
  # xfconf.settings = {
    
  # };
}