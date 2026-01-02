# https://nixos.wiki/wiki/Nvidia
# Reusable NVIDIA hardware acceleration and driver configuration
# Modeled after modules/hardware/hw-acceleration-amd.nix

{ config, pkgs, lib, ... }:

{
  # Prefer the proprietary NVIDIA driver and disable Nouveau
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Core NVIDIA driver settings
  hardware.nvidia = {
    # Choose a reasonable default package; override per-host if needed
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Enable kernel modesetting for better Wayland support and KMS console
    modesetting.enable = true;

    # Safe on desktops; useful for power control on some systems
    powerManagement.enable = true;

    # Install the NVIDIA settings control panel
    nvidiaSettings = true;

    # If your GPU supports the open kernel module, you can set:
    # open = true;
  };

  # Modern graphics configuration (replaces deprecated hardware.opengl)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit support for Steam/Wine/Proton
    # VA-API on NVIDIA via nvidia-vaapi-driver; VDPAU-VA bridges for compatibility
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
    # To enable Vulkan support for 32-bit applications, you can add:
    # extraPackages32 = [ pkgs.driversi686Linux.mesa ];
  };

  # Helpful userspace libraries
  environment.systemPackages = with pkgs; [
    libva
  ];
}
