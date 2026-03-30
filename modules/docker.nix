{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  networking.dhcpcd.denyInterfaces = [ "docker*" "ve*" "br*" ];
  users.extraGroups.docker.members = [ "luiz" ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
    liveRestore = false;
  };
}