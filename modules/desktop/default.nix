{ config, pkgs, lib, ... }:
{
  imports = [
    ./desktop-packages.nix
  ];

  # PipeWire sound server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Recommended for PipeWire
  security.rtkit.enable = true;

  # Flat mouse acceleration profile
  services.libinput = {
    enable = true;
    # mouse.accelProfile = "flat";
  };

  # Configure fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      arphic-ukai
      arphic-uming
      gohufont
      hack-font
      jetbrains-mono
      liberation_ttf
      symbola
      terminus_font
      ubuntu-classic
      wqy_microhei
      wqy_zenhei
    ];
    fontconfig = {
      useEmbeddedBitmaps = true;
      defaultFonts = {
        serif = [
          "Ubuntu"
          "Liberation Serif"
          "Noto Serif"
        ];
        sansSerif = [
          "Ubuntu"
          "Liberation Sans"
          "Noto Sans"
        ];
        monospace = [
          "Liberation Mono"
          "Ubuntu Mono"
          "Noto Sans Mono"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    copyq
    emote
    # helvum
    hunspell
    hunspellDicts.en_US
    # jamesdsp
    pavucontrol
  ];

  # Add support for XCompose
  # i18n.inputMethod.enabled = "ibus";

}
