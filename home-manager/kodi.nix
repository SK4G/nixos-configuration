{ config, pkgs, ... }:

{
  programs.kodi = {
    enable = true;
    package = pkgs.kodi.withPackages (exts: with exts; [
      # a4ksubtitles
      # iagl
      # inputstream-adaptive
      inputstreamhelper
      inputstream-ffmpegdirect
      keymap
      # netflix
      pvr-iptvsimple
      # steam-library
      # steam-launcher
      vfs-libarchive
      youtube
      # upnext
    ]);
  };
}