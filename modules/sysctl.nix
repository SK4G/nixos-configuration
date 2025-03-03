{ config, pkgs, lib, ... }:
{
  boot.kernel.sysctl = {
    # increase the size of the receive queue
    "net.core.netdev_max_backlog" = 100000;
    "net.core.netdev_budget" = 50000;
    "net.core.netdev_budget_usecs" = 5000;

    # increase the maximum connections
    "net.core.somaxconn" = 1024;

    # increase the memory dedicated to the network interfaces
    "net.core.rmem_default" = 1048576;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 1048576;
    "net.core.wmem_max" = 16777216;
    "net.core.optmem_max" = 65536;
    "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.udp_rmem_min" = 8192;
    "net.ipv4.udp_wmem_min" = 8192;

    # fix "neighbour: arp_cache: neighbor table overflow!"
    "net.ipv4.neigh.default.gc_thresh1" = 1024;
    "net.ipv4.neigh.default.gc_thresh2" = 2048;
    "net.ipv4.neigh.default.gc_thresh3" = 4096;

    # enable TCP Fast Open
    "net.ipv4.tcp_fastopen" = 3;

    # tweak the pending connection handling
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # enable MTU probing
    "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;

    # https://tldp.org/HOWTO/TCP-Keepalive-HOWTO/usingkeepalive.html
    "net.ipv4.tcp_keepalive_time" = 600;
    "net.ipv4.tcp_keepalive_intvl" = 60;
    "net.ipv4.tcp_keepalive_probes" = 5;

    # enable BBR
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # ipv6 privacy extensions
    # "net.ipv6.conf.default.use_tempaddr" = 1;

    # fix 12309
    "vm.dirty_bytes" = 67108864;
    "vm.dirty_background_bytes" = 33554432;
  };
}
