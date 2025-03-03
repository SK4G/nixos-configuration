{ config, lib, pkgs, ... }:
{
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # Enable touchpad support.
  # services.xserver.libinput = {
  #   enable = true;
  #   touchpad = {
  #     accelProfile = "flat";
  #     accelSpeed = "0.25";
  #     clickMethod = "clickfinger";
  #     sendEventsMode = "disabled-on-external-mouse";
  #   };
  # };
}
