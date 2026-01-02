{ config, pkgs, lib, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 51413 57066 ];
    allowedUDPPorts = [ 51413 57066 ];
  };
}