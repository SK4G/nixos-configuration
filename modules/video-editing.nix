{ config, pkgs, ... }:
# Davinci Resolve does not work with Valve kernel 6.5 
# It works with cachyos kernel 6.10
# https://discourse.nixos.org/t/davinci-resolve-studio-install-issues/37699/53

{
  nixpkgs.overlays = [
    (final: prev: {
      davinci-resolve-studio = prev.davinci-resolve-studio.override (old: {
        buildFHSEnv = a: (prev.buildFHSEnv (a // {
          extraBwrapArgs = a.extraBwrapArgs ++ [
            ''--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL''
            # redirect Resolve's "Extras" dir away from /nix/store to a writable location
            ''--bind ${config.xdg.dataHome or "$HOME/.local/share"}/DaVinciResolve/Extras /opt/resolve/Extras''
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
    ocenaudio
    peek
    davinci-resolve-studio
  ];

  hardware.graphics = {
    extraPackages = with pkgs; [
      # Davinci Resolve dependencies
      # rocmPackages.rocminfo
      rocmPackages.clr.icd
      # mesa.opencl
    ];
  };
  hardware.amdgpu.opencl.enable = true;

  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];

  hardware.graphics = {
    enable32Bit = true;
  };
}


# { config, pkgs, ... }:

# let
#   # Pin DaVinci Resolve to commit 2a574fe34c894ef2a343ee006f4228f4e006e5b9
#   resolvePin = builtins.fetchTarball {
#     url = "https://github.com/NixOS/nixpkgs/archive/2a574fe34c894ef2a343ee006f4228f4e006e5b9.tar.gz";
#     sha256 = "1ipqwcpi3s6p0vh5yw7v4127c6774iwwlq6ig1xm9ycmaz5dx8vm";
#   };
  
#   resolvePkgs = import resolvePin { 
#     system = pkgs.stdenv.hostPlatform.system; 
#     config.allowUnfree = true;
#   };
# in
# {
#   nixpkgs.overlays = [
#     (final: prev: {
#       davinci-resolve-studio = resolvePkgs.davinci-resolve-studio.override (old: {
#         buildFHSEnv = a: (prev.buildFHSEnv (a // {
#           extraBwrapArgs = a.extraBwrapArgs ++ [
#             "--ro-bind /run/opengl-driver/etc/OpenCL /etc/OpenCL"
#           ];
#         }));
#       });
#     })
#   ];

#   environment.systemPackages = with pkgs; [
#     davinci-resolve-studio
#     libGLU
#     libGL
#     libx11
#     libxext
#     libxrender
#     freetype
#     fontconfig
#   ];

#   hardware.graphics.extraPackages = with pkgs; [
#     rocmPackages.rocm-runtime
#     rocmPackages.rocminfo
#     rocmPackages.clr.icd
#     # driversi686Linux.mesa
#     # mesa.opencl
#     # khronos-ocl-icd-loader
#   ];

#   hardware.amdgpu.opencl.enable = true;
  
#   systemd.tmpfiles.rules = [
#     "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
#     "w /sys/module/amdgpu/parameters/vm_fragment_size - - - - 9"
#   ];
 
#   boot.kernel.sysctl = {
#     "vm.max_map_count" = 2147483642;
#     "vm.overcommit_memory" = 1;
#   };
#   hardware.graphics = {
#     enable32Bit = true;
#   };
# }