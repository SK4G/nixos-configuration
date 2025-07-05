{ config, pkgs, ... }:
# Davinci Resolve does not work with Valve kernel 6.5 
# It works with cachyos kernel 6.10
# https://discourse.nixos.org/t/davinci-resolve-studio-install-issues/37699/53

{
  nixpkgs.overlays = [
    (final: prev: {
      davinci-resolve = prev.davinci-resolve.override (old: {
        buildFHSEnv = a: (prev.buildFHSEnv (a // {
          extraBwrapArgs = a.extraBwrapArgs ++ [
            ''--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL''
          ];
        }));
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    gimp
    inkscape
    ffmpeg
    obs-studio 
    obs-studio-plugins.obs-vkcapture
    # ocenaudio
    peek
    # davinci-resolve
    davinci-resolve-studio
    # kdenlive
    # simplescreenrecorder
  ];

  hardware.graphics = {
    extraPackages = with pkgs; [
      # Davinci Resolve dependencies
      # rocm-opencl-icd
      # rocm-opencl-runtime
      # rocmPackages.rocm-runtime
      # rocmPackages.rocminfo
      rocmPackages.clr.icd
      # mesa.opencl
    ];
  };
  hardware.amdgpu.opencl.enable = true;

}
