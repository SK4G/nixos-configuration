{ config, pkgs, ... }:

{
  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    # needed for virtfs host to guest sharing
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };

  virtualisation.spiceUSBRedirection.enable = true;
  
  users.groups.libvirtd.members = ["luiz"];
  users.users.luiz = {
    extraGroups = [ "libvirtd" ];
  };

  services.envfs.enable = true;
}
