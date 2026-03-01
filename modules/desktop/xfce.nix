{ config, pkgs, ... }:

{
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];
  
  environment.systemPackages = with pkgs; [    
    lxappearance
    xfce4-appfinder
    xfce4-battery-plugin
    xfce4-clipman-plugin
    # xfce4-netload-plugin
    xfce4-power-manager
    xfce4-screenshooter
    # xfce4-sensors-plugin
    xfce4-settings
    xfce4-taskmanager
    xfce4-xkb-plugin
    # xfce4-weather-plugin

    catfish
    xfce4-exo
    garcon
    mousepad
    ristretto
    #thunar
    #thunar-archive-plugin
    #thunar-volman
    tumbler
    xfconf
    # xfwm4
];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  powerManagement.enable = true;
  # xfconf.settings = {
    
  # };
}