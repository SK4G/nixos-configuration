{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    appimage-run
    # asciinema
    bash-completion
    bat
    btop
    curl
    dex
    duf
    e2fsprogs
    exfatprogs
    # etcher
    # easytag
    glib
    gromit-mpx
    # hblock
    hw-probe
    hwinfo
    inxi
    lm_sensors
    lshw
    most
    # nano
    ncdu
    neofetch
    # resilio-sync
    # sshpass
    # ventoy
    # virt-manager
    p7zip
    # gnome-disk-utility
    # gnome-keyring
    # gnumake
    gparted
    # guvcview
    joplin-desktop
    jq
    # jsoncpp
    imagemagick
    # imlib2
    # libmtp
    # lsb-release
    # numlockx
    ookla-speedtest
    ripgrep
    # sof-firmware
    # sshpass
    spotdl
    sysz
    texliveBasic
    tree
    unrar
    unzip
    xclip
    # xdotool
    wget
    # volumeicon
    yt-dlp
    xdotool
    # xorg.libX11.dev
    # xorg.libXft
    # xorg.libXinerama

    ###file management
    # mtpfs
    # udiskie
    # isoimagewriter
    usbimager

    ### Benchmarks
    # passmark-performancetest
    # unigine-heaven
    # phoronix-test-suite
  ];
}
