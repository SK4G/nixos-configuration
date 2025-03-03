{ config, pkgs, lib, ... }:
{
  services.xserver.dpi = 144;
  services.xserver.upscaleDefaultCursor = true;
  environment.variables = {
    # GDK_SCALE = "2.2";
    # GDK_DPI_SCALE = "0.4";
    # _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2.2";
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    XCURSOR_SIZE = "32";
  };
}
