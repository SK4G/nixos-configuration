{ config, pkgs, ... }:
# https://nixos.wiki/wiki/Xfce

# Using xfce as a desktop manager with another window manager is needed
# for xfce utilities such as xfce4-power-manager to work

{
  services.xserver.desktopManager.xfce = {
    enable = true;
    noDesktop = true;
    enableXfwm = false;
    # enableWaylandSession = true;
    # waylandSessionCompositor = "labwc --startup"
  };

  services.gnome.gnome-keyring.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  # startx must be enabled for gamescope x sessions to be started
  services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.startx.generateScript = true;
  services.displayManager.defaultSession = "xfce+awesome";
  services.xserver.windowManager.awesome.enable = true;
  services.xserver.windowManager.awesome = {
    luaModules = with pkgs.luaPackages; [
      luarocks # is the package manager for Lua modules
      luadbi-mysql # Database abstraction layer
    ];
  };

  imports =
    [
      ./xfce.nix
    ];

  environment.systemPackages = with pkgs; [
    arandr
    autorandr
    brightnessctl
    conky
    dmenu
    killall
    # luajitPackages.vicious
    picom

    arc-theme
    font-manager
    dconf-editor
    file-roller
    gnome-disk-utility
    gvfs
    file-roller
    networkmanagerapplet
    rofi
    # rxvt-unicode
    widevine-cdm
    xkill
  ];

  fonts.packages = with pkgs; [
    # terminus_font
    # terminus_font_ttf
    # terminus-nerdfont
  ];

}
