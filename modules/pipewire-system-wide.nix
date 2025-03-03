{ config, pkgs, ... }:
{
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.socketActivation = false;
  services.pipewire.systemWide = true;

  systemd.services.pipewire = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.MemoryDenyWriteExecute = "false";
  };

  sound.enable = true;
}
