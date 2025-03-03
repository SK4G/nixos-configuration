{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    luiz = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "adbusers"
        "audio"
        "dialout"
        "docker"
        "lp"
        "networkmanager"
        "plugdev"
        "scanner"
        "storage"
        "video"
        "wheel" # Enable ‘sudo’ for the user.
      ];
    #   openssh.authorizedKeys.keys = [
    #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/k1reOfT7csrtHnbp9ti+oyBlY8sS4DEeRmhJRPFJe luiz@naomi"
    #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPxq3an5irer/8bjJFK0ZzXbOExSp/T7DNsLx/xtMBj luiz@erika"
    #   ];
    # };
    # root = {
    #   openssh.authorizedKeys.keys = [
    #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAS7kK0u31sBUIwC7Bf6KT3hmPSEMAAlMAdKMF36Kp/ deploy@gitlab-ci"
    #   ] ++ config.users.users.luiz.openssh.authorizedKeys.keys;
    };
  };

  # Disble password promt
  # security.sudo.wheelNeedsPassword = false;

  security.sudo = {
    enable = true;
    extraRules = [{
        commands = [
        {
            command = "${pkgs.systemd}/bin/systemctl suspend";
            options = [ "NOPASSWD" ];
        }
        {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
        }
        {
            command = "${pkgs.systemd}/bin/poweroff";
            options = [ "NOPASSWD" ];
        }
        {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
        }                
        ];
        groups = [ "wheel" ];
    }];
  };
}
