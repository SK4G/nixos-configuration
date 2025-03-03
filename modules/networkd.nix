{ config, pkgs, ... }:
{
  boot.initrd.systemd.enable = true;

  networking.useNetworkd = true;

  # https://github.com/NixOS/nixpkgs/issues/247608
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
}
