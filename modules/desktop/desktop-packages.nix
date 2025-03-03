{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # discord
    evince
    feh
    # filezilla
    # firefox
    # flameshot
    # chromium
    # google-chrome
    haruna
    # kate
    lxappearance
    # micro
    mpv
    # nitrogen
    # protonvpn-cli
    # pywal
    scrcpy
    # telegram-desktop
    vvave
    # variety
    vivaldi
    vivaldi-ffmpeg-codecs
    # vlc
    # xournalpp
    # zoom

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