{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    # wpsoffice
    # xournalpp
  ];

  # Don't use any user config
  fonts.fontconfig.includeUserConf = false;
  
  fonts.fontconfig.enable = true;
  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    # ms fonts
    corefonts
    vista-fonts

    aileron            # Used for user interface
    go-font            # Main monospace font
    noto-fonts         # fallback font
    noto-fonts-cjk-sans     # fallback font
    noto-fonts-color-emoji
    font-awesome       # Used for misc symbols

    # Misc additional fonts
    dejavu_fonts
    # font-awesome
    inconsolata
    proggyfonts
    roboto
    source-code-pro
    source-sans-pro
    source-serif-pro
    # terminus_font
    (google-fonts.override { fonts = [ "Nunito" ]; })
    # (nerd-fonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Configure emoji font
  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <match target="scan">
        <test name="family">
          <string>Noto Color Emoji</string>
        </test>
        <edit name="scalable" mode="assign">
          <bool>true</bool>
        </edit>
      </match>

      <match target="pattern">
        <test name="prgname">
          <string>chrome</string>
        </test>
        <edit name="family" mode="prepend_first">
          <string>Noto Color Emoji</string>
        </edit>
      </match>
    </fontconfig>
  '';
}
