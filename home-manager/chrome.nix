{ config, pkgs, ... }:

{
  # configuring extensions is not supported
  programs.google-chrome = {
    enable = true;
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        # "--ignore-gpu-blocklist"
        # "--enable-features=UseOzonePlatform"
        # "--ozone-platform=wayland"
      ];
  };

}
