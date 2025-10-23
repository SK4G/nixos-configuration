{ config, pkgs, inputs, ... }:

{  
  environment.systemPackages = with pkgs; [
    # drivers
    dxvk
    vkd3d
    vkd3d-proton

    # streamdeck-ui
    # emulationstation-de
    # cemu
    # heroic
    (lutris.override {
       extraPkgs = pkgs: [
         wine
         winetricks
       ];
    })
    # mangohud
    # steam-rom-manager
    # yuzuPackages.early-access
    # inputs.yuzu.packages.${pkgs.system}.early-access
    # rpcs3

    # (retroarch.override {
    #   cores = with libretro; [
    #     bsnes
    #     # citra
    #     desmume
    #     # melonds
    #     dolphin
    #     # flycast
    #     mame
    #     gambatte
    #     mgba
    #     mupen64plus
    #     nestopia
    #     # parallel-n64
    #     pcsx2
    #     # ppsspp
    #     # vba-next
    #     genesis-plus-gx
    #     snes9x
    #     beetle-psx-hw
    #   ];
    # })
  ];

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
    gamemode.enable = true;
  };
  
  # hardware.amdgpu.overdrive.ppfeaturemask = "0xffffffff";
  # hardware.graphics = {
  #   ## radv: an open-source Vulkan driver from freedesktop
  #   driSupport = true;
  #   driSupport32Bit = true;
  # };
}
