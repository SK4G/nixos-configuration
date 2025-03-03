{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    arc-kde-theme
    bibata-cursors
    kdePackages.breeze-icons
  ];

  home.sessionVariables = {
    # EDITOR = "emacs";
    XCURSOR_THEME = "Bibata-Modern-Ice";
  };
  
  xresources.properties = {
    "Xft.dpi" = 144;
    "Xcursor.theme" = "Bibata-Modern-Ice";
  };
  xsession = {
    initExtra = "xrdb -merge ~/.Xresources";
    # numlock.enable = true;
  };
  
  gtk = {
    enable = true;
    theme.name = "Arc-Dark";
    cursorTheme.name = "Bibata-Modern-Ice";
    iconTheme.name = "Sardi-Arc";
    # iconTheme.name = "breeze-dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Arc-Dark";
      cursor-theme = "Bibata-Modern-Ice";
      icon-theme = "Sardi-Arc";
    };
  };

  # gtk = {
  #   enable = true;
  #   iconTheme = {
  #     package = pkgs.arc-icon-theme;
  #     name = "Arc";
  #   };
  #   theme = {
  #     package = pkgs.arc-theme;
  #     name = "Arc-Dark";
  #   };
  #   gtk3.extraConfig = {
  #     gtk-application-prefer-dark-theme = true;
  #   };
  #   # font = {
  #   #   name = "Ubuntu";
  #   #   size = 10;
  #   # };
  # };
  #   home.pointerCursor = {
  #   name = "Vanilla-DMZ-AA";
  #   size = 16;
  #   package = pkgs.vanilla-dmz;
  #   x11.enable = true;
  #   gtk.enable = true;
  # };
}
