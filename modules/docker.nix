{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  networking.dhcpcd.denyInterfaces = [ "docker*" "ve*" "br*" ];
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
    autoPrune.enable = true;
    autoPrune.dates = weekly;
  };
}
