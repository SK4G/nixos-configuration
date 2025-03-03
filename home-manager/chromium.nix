{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm"      # ublock origin
      "olcfgpmjldkkjdclidhcbonieibfhhdh"      # fullscreen anything
      "ncppfjladdkdaemaghochfikpmghbcpc"      # open as popup
      # "lmjnegcaeklhafolokijcfjliaokphfk"    # videodownloadhelper
      ];
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        # "--ignore-gpu-blocklist"
        # "--enable-features=UseOzonePlatform"
        # "--ozone-platform=wayland"
      ];
  };

}
