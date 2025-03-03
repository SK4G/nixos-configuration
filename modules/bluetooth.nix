{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    blueberry
  ];

  hardware.bluetooth = {
    enable = true;
    # settings = {
    #   General = {
    #     Disable = "Headset";
    #   };
    # };
  };
}
