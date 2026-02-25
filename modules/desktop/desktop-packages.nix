{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # discord
    evince
    feh
    # google-chrome
    lxappearance
    mpv
    vivaldi
    vivaldi-ffmpeg-codecs
    # vlc
    # xournalpp

    #### media
    # jellyfin
    # does not install kodi addons correctly. use home manager
  #   kodi
  #   # plex
  ];
  # ] ++ (with kodiPackages; [
  #     # a4ksubtitles
  #     # iagl
  #     # inputstream-adaptive
  #     keymap
  #     # netflix
  #     # steam-library
  #     # steam-launcher
  #     youtube
  #     upnext
  # ]);
}