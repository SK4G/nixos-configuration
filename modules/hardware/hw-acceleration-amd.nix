# https://nixos.wiki/wiki/AMD_GPU
# https://linuxreviews.org/HOWTO_fix_screen_tearing
# This module fixes screen tearing on amdgpu
# Ensure output is "radeonsi"
# grep -iE 'vdpau | dri driver' ~/.local/share/xorg/Xorg.0.log

{ config, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver = {
    enableTearFree = true;
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      libvdpau-va-gl
      vaapiVdpau
    ];
  };

  # To enable Vulkan support for 32-bit applications, also add:
  hardware.graphics.extraPackages32 = [
    pkgs.driversi686Linux.amdvlk
  ];

  # Force radv
  # environment.variables.AMD_VULKAN_ICD = "RADV";

  environment.systemPackages = with pkgs; [
    libva
  ];

}
