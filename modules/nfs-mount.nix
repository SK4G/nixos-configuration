{ config, pkgs, ... }:

{
  services.rpcbind.enable = true; # needed for NFS
  # systemd.mounts = [{
  #   type = "nfs";
  #   mountConfig = {
  #     Options = "noatime,nofail,noauto";
  #   };
  #   what = "192.168.1.65:/mnt/Seagate-14TB";
  #   where = "/home/luiz/SeagateNFS";
  # }];

  # systemd.automounts = [{
  #   wantedBy = [ "multi-user.target" ];
  #   automountConfig = {
  #     TimeoutIdleSec = "600";
  #   };
  #   where = "/home/luiz/SeagateNFS";
  # }];

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];
}