{ config, ... }: {
  imports = [
    # ./automatic-updater.nix
    ./make-linux-fast-again.nix
    ./nix-config.nix
  ];
}
