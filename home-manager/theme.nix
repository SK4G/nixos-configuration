{ config, pkgs, lib, host, ... }:

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
  
  xresources.properties = lib.mkMerge [
    {
      "Xcursor.theme" = "Bibata-Modern-Ice";
    }
    (lib.mkIf (host == "deck") {
      "Xft.dpi" = 144;
    })
  ];
  xsession = {
    initExtra = "xrdb -merge ~/.Xresources";
    # numlock.enable = true;
  };
  
  gtk = {
    enable = true;
    theme.name = "Vapor";
    cursorTheme.name = "Bibata-Modern-Ice";
    iconTheme.name = "Sardi-Arc";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Vapor";
      cursor-theme = "Bibata-Modern-Ice";
      icon-theme = "Sardi-Arc";
    };
  };

  # Ensure Sardi-Arc inherits breeze-dark for toolbar and action icons
  xdg.dataFile."icons/Sardi-Arc/index.theme".text = ''
    [Icon Theme]
    Name=Sardi Arc
    Comment=Simple and flat icon theme with long shadow
    Inherits=breeze-dark,breeze,hicolor
    Example=folder

    DisplayDepth=32
    DesktopDefault=48
    DesktopSizes=16,22,32,48,64,128,256
    ToolbarDefault=22
    ToolbarSizes=16,22,32,48
    MainToolbarDefault=22
    MainToolbarSizes=16,22,32,48
    SmallDefault=16
    SmallSizes=16,22,32,48
    PanelDefault=32
    PanelSizes=16,22,32,48,64,128,256
    DialogDefault=32
    DialogSizes=16,22,32,48,64,128,256

    Directories=places/16,places/22,places/24,places/32,places/48,places/64,places/96,places/128

    [places/16]
    Size=16
    Context=Places
    Type=Fixed

    [places/22]
    Size=22
    Context=Places
    Type=Fixed

    [places/24]
    Size=24
    Context=Places
    Type=Fixed

    [places/32]
    Size=32
    Context=Places
    Type=Fixed

    [places/48]
    Size=48
    Context=Places
    Type=Fixed

    [places/64]
    Size=64
    Context=Places
    Type=Fixed

    [places/96]
    Size=96
    Context=Places
    Type=Fixed

    [places/128]
    Size=128
    Context=Places
    Type=Fixed
  '';

  # Map clipman-symbolic to Breeze-Dark's white paste icon
  xdg.dataFile."icons/hicolor/scalable/apps/clipman-symbolic.svg".source =
    "${pkgs.kdePackages.breeze-icons}/share/icons/breeze-dark/actions/16/edit-paste-symbolic.svg";
}
