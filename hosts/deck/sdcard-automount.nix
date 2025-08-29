{ pkgs, ... }:
{
  systemd.services.sdcard-automount = {
    description = "Steam Deck SD Card automount";

    # Run after the SD card block device is available
    after = [ "dev-mmcblk0p1.device" ];
    requires = [ "dev-mmcblk0p1.device" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.udisks2}/bin/udisksctl mount --no-user-interaction -b /dev/mmcblk0p1";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
