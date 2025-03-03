{ config, ... }: {
  imports = [
    # ./automatic-updater.nix
    ./make-linux-fast-again.nix
    ./nixos-updater.nix
  ];
}
