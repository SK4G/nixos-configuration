{ config, pkgs, ... }:

{
  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;
  
  users.groups.libvirtd.members = ["luiz"];
  users.users.luiz = {
    extraGroups = [ "libvirtd" ];
  };
}
