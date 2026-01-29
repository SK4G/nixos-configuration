{ pkgs, ... }:

{
  imports = [
    ./ubuntu-lineageos-dev.nix
  ];

  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemd-nspawn";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemd-nspawn";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/usr/bin/test";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/usr/bin/mkdir";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/usr/bin/rm";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.debootstrap}/bin/debootstrap";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/debootstrap";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}