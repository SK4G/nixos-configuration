# Causes slow launch of GTK apps
# https://bbs.archlinux.org/viewtopic.php?id=270280

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [

  ];
  # Use the first portal implementation found in lexicographical order
  # xdg.portal.config.common.default = "*";
  
  xdg = {
    enable = true;
    portal.enable = true;
    portal.configPackages = [ pkgs.xdg-desktop-portal-gtk ];
    portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-user-dirs ];
    mimeApps = {
      enable = true;

      defaultApplications = {
        "application/x-bittorrent" = "de.haeckerfelix.Fragments.desktop";
        "application/x-ms-dos-executable" = "wine.desktop";
        "application/x-shellscript" = "org.xfce.mousepad.desktop";
        "application/x-wine-extension-ini" = "org.xfce.mousepad.desktop";
        "application/zip" = "org.gnome.FileRoller.desktop";
        "image/avif" = "org.xfce.ristretto.desktop";
        "image/jpeg" = "org.xfce.ristretto.desktop";
        "image/png" = "org.xfce.ristretto.desktop";
        "image/svg+xml" = "org.xfce.ristretto.desktop";
        "text/html" = "google-chrome.desktop";
        "text/plain" = "org.xfce.mousepad.desktop";
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
      };
    };
  };
}
