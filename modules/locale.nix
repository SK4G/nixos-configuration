{ config, lib, pkgs, ... }:

with lib; {
  # Select internationalization properties.
  # console =  {
  #   earlySetup = mkDefault true;
  #   font = mkDefault "ter-v16n";
  #   packages = [ pkgs.terminus_font ];
  #   useXkbConfig = mkDefault true;
  # };

  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Set your time zone.
  time.timeZone = mkDefault "America/Chicago";
}
