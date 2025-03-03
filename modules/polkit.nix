{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # breeze-gtk
    # breeze-icons
    accountsservice
    polkit
    polkit_gnome
  ];

  security.polkit.enable = true;
  
  programs.dconf.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };
}
