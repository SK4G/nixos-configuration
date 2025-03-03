{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    grobi
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

  services.grobi = {
    enable = true;
    rules = [
      {
        name = "docked";
        outputs_connected = [ "DisplayPort-0" "eDP" ];
        atomic = false;
        configure_column = [ "DisplayPort-0" "eDP" ];
        primary = "DisplayPort-0";
        execute_after = [
          ".bin/conky-toggle"
          "xrdb -merge ~/.Xresources"
          # "awesome-client 'awesome.restart()'"
          "conky -c $HOME/.config/awesome/system-overview"
          # "${pkgs.nitrogen}/bin/nitrogen --restore"
          # "${pkgs.networkmanager}/bin/nmcli radio wifi off"
        ];
      }
      {
        name = "undocked";
        outputs_disconnected = [ "eDP" ];
        configure_single = "eDP";
        primary = true;
        atomic = true;
        execute_after = [
          "conky -c $HOME/.config/awesome/system-overview"
          # "${pkgs.nitrogen}/bin/nitrogen --restore"
          # "${pkgs.networkmanager}/bin/nmcli radio wifi on"
        ];
      }
      {
        name = "fallback";
        configure_single = "eDP";
      }
    ];
  };
}
