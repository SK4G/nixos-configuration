{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.userSettings.music;
in
{
  options = {
    userSettings.music = {
      enable = lib.mkEnableOption "Enable apps for making music";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rosegarden
      mediainfo
      easytag
      bottles

      # The following requires 64-bit FL Studio (FL64) to be installed to a bottle
      # With a bottle name of "FL Studio"
      (pkgs.writeShellScriptBin "flstudio" ''
        #!/bin/sh
        set -e
        if [ -z "$1" ]; then
          exec ${pkgs.bottles}/bin/bottles-cli run -b "FL Studio" -p FL64
        else
          filepath=$(${pkgs.bottles}/bin/bottles-cli winepath -b "FL Studio" --windows "$1")
          exec ${pkgs.bottles}/bin/bottles-cli run -b "FL Studio" -p FL64 --args "$filepath"
        fi
      '')

      (pkgs.makeDesktopItem {
        name = "flstudio";
        desktopName = "FL Studio 64";
        exec = "flstudio %U";
        terminal = false;
        type = "Application";
        icon = "flstudio";
        mimeTypes = [ "application/octet-stream" ];
      })

      (pkgs.stdenv.mkDerivation {
        name = "flstudio-icon";
        # icon from https://www.reddit.com/r/MacOS/comments/jtmp7z/i_made_icons_for_discord_spotify_and_fl_studio_in/
        dontUnpack = true;
        src = ./flstudio.png;

        installPhase = ''
          mkdir -p $out/share/pixmaps
          cp $src $out/share/pixmaps/flstudio.png
        '';
      })
    ];

    # Automate bottle creation and setup
    home.activation.flStudioBottle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create bottle if missing
      ${pkgs.bottles}/bin/bottles-cli new \
        --bottle-name "FL Studio" \
        --environment "Application" \
        --runner "kron4ek-wine-11.5-staging-amd64" || true

      # Install dependencies
      ${pkgs.bottles}/bin/bottles-cli tools \
        --bottle "FL Studio" \
        --install allfonts || true

      # Set Windows 11 compatibility (optional)
      ${pkgs.bottles}/bin/bottles-cli set-config \
        --bottle "FL Studio" \
        --key "versioning_wine_version" \
        --value "win11" || true
    '';

    xdg.mimeApps.associations.added = {
      "application/octet-stream" = [ "flstudio.desktop" ];
    };

    # Ensure the icon is linked so the desktop environment can find it
    home.file.".local/share/icons/flstudio.png".source = ./flstudio.png;
  };
}