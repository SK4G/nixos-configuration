{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.services.lustrate;
in {
  options.services.lustrate = {
    enable = mkEnableOption "Lustrate root filesystem";
    keep = mkOption {
      type = types.listOf types.str;
      example = [
        "home"
        "var/log/journal"
      ];
      description = ''
        Keep only these directory.
      '';
    };
  };
  config = mkIf cfg.enable {
    boot.initrd.postMountCommands = ''
      softLustrateRoot () {
        local root="$1"
        echo
        echo -e "\e[1;33m<<< NixOS is now lustrating the root filesystem (cruft goes to /old-root) >>>\e[0m"
        echo
        mkdir -m 0755 -p "$root/old-root.tmp"
        echo
        echo "Moving impurities out of the way:"
        # remove old root
        chattr -i "$root/old-root/var/empty"
        rm -rf "$root/old-root"
        for d in "$root"/*
        do
          [ "$d" == "$root/nix"          ] && continue
          [ "$d" == "$root/boot"         ] && continue # Don't render the system unbootable
          [ "$d" == "$root/old-root.tmp" ] && continue
          mountpoint -q "$d"               && continue
          mv -v "$d" "$root/old-root.tmp"
        done
        # Use .tmp to make sure subsequent invokations don't clash
        mv "$root/old-root.tmp" "$root/old-root"
        chattr -i "$root/old-root/var/empty"
        mkdir -m 0755 -p "$root/etc"
        touch "$root/etc/NIXOS"
        echo
        echo "Restoring selected impurities:"
        echo -e "${concatStringsSep "\\n" cfg.keep}" | while IFS= read -r keeper; do
          mountpoint -q "$root/$keeper" && continue
          dirname="$(dirname "$keeper")"
          mkdir -m 0755 -p "$root/$dirname"
          mv -v "$root/old-root/$keeper" "$root/$keeper"
        done
        exec 4>&-
      }
      softLustrateRoot "/mnt-root"
    '';
  };
}
