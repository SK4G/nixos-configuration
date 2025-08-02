{ config, pkgs, lib, ... }:
{
  nix.settings = {
    trusted-users = [ "@wheel" ];
  };

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 14d";
  };

  # Enable automatic updates
  systemd.timers.nixos-upgrade = {
    enable = true;
    timerConfig.OnCalendar = "weekly";
    wantedBy = [ "timers.target" ];
  };

  systemd.services.nixos-upgrade = {
    script = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --upgrade";
    serviceConfig.Type = "oneshot";
  };

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
    permittedInsecurePackages = [
      "adobe-reader-9.5.5"
      "freeimage-unstable-2021-11-01"
    ];
  };
  
  programs.nix-ld.enable = true;
}
