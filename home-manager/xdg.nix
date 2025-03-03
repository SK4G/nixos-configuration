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
    portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    desktopEntries = {
      # Firefox PWA
      pwas = {
        exec =
          "firefox --no-remote -P PWAs --name pwas ${config.applications.firefox.pwas.sites}";
        icon = "firefox";
        name = "Firefox PWAs";
        terminal = false;
        type = "Application";
      };

    #   Run signal without a tray icon
    #   signal = {
    #     exec = "signal-desktop --hide-tray-icon";
    #     icon = "signal-desktop";
    #     name = "Signal - No tray";
    #     terminal = false;
    #     type = "Application";
    #   };
    # };

      # Default apps
      mimeApps = {
        enable = true;

        defaultApplications = {
          # "application/pdf" = "google-chrome.desktop";
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
    #   desktopEntries = {
    #     firefox = {
    #     name = "Firefox";
    #     genericName = "Web Browser";
    #     exec = "firefox %U";
    #     terminal = false;
    #     categories = [ "Application" "Network" "WebBrowser" ];
    #     mimeType = [ "text/html" "text/xml" ];
    #   }
    # };

    # desktopEntries.<name>.actions = {
    #   "New Window" = {
    #     exec = "${pkgs.firefox}/bin/firefox --new-window %u";
    #   };
    # };
    
    # xdg.desktopEntries = {
    #   firefox.icon = "icon-name.png";
    # };
    };
  };
}
