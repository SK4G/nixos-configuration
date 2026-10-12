{ config, pkgs, ... }:

{
  # configuring extensions is not supported
  programs.google-chrome = {
    enable = true;
    commandLineArgs = [
      "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiIgnoreDriverChecks,VaapiVideoDecoder"
      "--ignore-gpu-blocklist"
      "--enable-zero-copy"
      "--enable-gpu-rasterization"
    ];
  };

}
