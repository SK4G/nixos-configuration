# https://nixos.wiki/wiki/AMD_GPU
# https://linuxreviews.org/HOWTO_fix_screen_tearing
# This module fixes screen tearing on amdgpu
# Ensure output is "radeonsi"
# grep -iE 'vdpau | dri driver' ~/.local/share/xorg/Xorg.0.log

{ config, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  # AMDGPU specific settings to reduce DMCUB errors
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amdgpu.dc=1"
    "amdgpu.debug=dmcub"
    "amdgpu.no_wb=0"
  ];

  services.xserver = {
    enableTearFree = true;
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
      libva-vdpau-driver
    ];
  };

  # To enable Vulkan support for 32-bit applications, also add:
  # hardware.graphics.extraPackages32 = [
  #   pkgs.driversi686Linux.mesa
  # ];

  # Force radv
  # environment.variables.AMD_VULKAN_ICD = "RADV";

  environment.systemPackages = with pkgs; [
    libva
  ];

}
