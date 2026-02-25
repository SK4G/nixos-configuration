{ config, lib, pkgs, ... }:
{
  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
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
