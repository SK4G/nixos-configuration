{ config, lib, pkgs, ... }:
let
  qemuPackage = pkgs.qemu_kvm;
  qemuMachine = {
    x86_64-linux = "pc";
    aarch64-linux = "virt,gic-version=host";
  }.${pkgs.stdenv.hostPlatform.system};
  haosImage = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/home-assistant/operating-system/releases/download/11.5/haos_ova-11.5.qcow2.xz";
      hash = "sha256-AJeha0NgrEU+4iGTdflmUN6CN12HFB0Q/rYK9ttL6UM=";
    };
  }.${pkgs.stdenv.hostPlatform.system};
  cfg = config.services.haos;
in
{
  options = {
    services.haos = {
      enable = lib.mkEnableOption "HAOS";
      cpu = lib.mkOption {
        type = lib.types.str;
        default = "host";
        description = "Passed as -cpu argument to qemu.";
      };
      smp = lib.mkOption {
        type = lib.types.str;
        default = "cores=2";
        description = "Passed as -smp argument to qemu.";
      };
      machine = lib.mkOption {
        type = lib.types.str;
        default = qemuMachine;
        description = "qemu machine";
      };
      mem = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "memory size in gb.";
      };
      bridge = lib.mkOption {
        type = lib.types.str;
        example = "br0";
        description = "Bridge used for networking.";
      };
      mac = lib.mkOption {
        type = lib.types.str;
        description = "Mac address used for networking.";
      };
      serialPassthrough = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of serial devices.";
        default = [ ];
        example = [ "/dev/ttyUSB0" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # required for using bridges in qemu
    environment = {
      etc."qemu/bridge.conf".text = "allow ${cfg.bridge}";
      etc.ethertypes.source = "${pkgs.iptables}/etc/ethertypes";
    };

    # needed for running quemu as non-root user
    security.wrappers.qemu-bridge-helper = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${qemuPackage}/libexec/qemu-bridge-helper";
    };

    # reuse qemu user from libvirtd
    users.groups.qemu-libvirtd = {
      gid = config.ids.gids.qemu-libvirtd;
    };

    users.users.qemu-libvirtd = {
      uid = config.ids.uids.qemu-libvirtd;
      isNormalUser = false;
      group = "qemu-libvirtd";
    };

    systemd.services.haos = {
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ qemuPackage qemu-utils socat xz ];
      script = ''
        set -euo pipefail

        disk=disk1.qcow2
        if [ ! -f $disk ]; then
          xz -dc ${haosImage} > $disk
        fi

        exec qemu-kvm \
          -nographic \
          -cpu ${cfg.cpu} \
          -smp ${cfg.smp} \
          -M ${cfg.machine} \
          -m ${toString cfg.mem}G \
          -drive if=pflash,format=raw,unit=0,readonly=on,file=${pkgs.OVMF.firmware} \
          -drive if=pflash,format=raw,unit=1,readonly=on,file=${pkgs.OVMF.variables} \
          -netdev bridge,id=hn0,helper=/run/wrappers/bin/qemu-bridge-helper,br=${cfg.bridge} \
          -device virtio-net-pci,netdev=hn0,id=nic0,mac=${cfg.mac} \
          -device virtio-balloon \
          -device virtio-rng-pci \
          -object iothread,id=iothread0 \
          -device virtio-scsi-pci,iothread=iothread0,id=scsi0 \
          -device scsi-hd,drive=hd0,bus=scsi0.0,serial=disk1 \
          -drive if=none,id=hd0,file=$disk,format=qcow2,discard=unmap \
          ${lib.concatStringsSep " \\\n" (lib.imap0 (i: v: "-chardev serial,path=${v},id=chardev${toString i} -device pci-serial,chardev=chardev${toString i}") cfg.serialPassthrough)} \
          -chardev socket,path=qga.sock,server=on,wait=off,id=qga0 \
          -device virtio-serial \
          -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 \
          -monitor unix:qemu.monitor,server,nowait \
          -vnc :0
      '';
      preStop = ''
        echo '{"execute": "guest-shutdown"}' | socat stdio,ignoreeof ./qga.sock
      '';
      serviceConfig = {
        SupplementaryGroups = "dialout";
        User = "qemu-libvirtd";
        TimeoutStopSec = 15 * 60;
        Restart = "on-failure";
        StateDirectory = "haos";
        WorkingDirectory="/var/lib/haos";
      };
    };
  };
}
