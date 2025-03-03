# NixOS configuration


## Install

```bash
# https://nixos.org/manual/nixos/stable/index.html#sec-installation
mkdir -p /mnt/etc/nixos/
cd /mnt/etc/nixos/
nix-shell -p git
git clone https://github.com/luiz/nixos-configuration.git
cd nixos-configuration
# Generate new configuration.nix, update flake.nix
mkdir hosts/<hostname>
nixos-generate-config --root /mnt --dir hosts/<hostname>
# Install system
nixos-install --root /mnt --impure --no-channel-copy --flake .#<hostname>
# Set password for `luiz` user
nixos-enter --root /mnt -c 'passwd luiz'
# Reboot
reboot
```

## Apply configuration

```bash
nixos-rebuild switch -L --use-remote-sudo --fast --flake /etc/nixos/nixos-configuration
```


## Upgrade

```bash
nix flake update --commit-lock-file
nixos-rebuild boot -L --use-remote-sudo --fast --flake .
sudo reboot
```


## Rollback upgrade

```bash
git revert HEAD
nixos-rebuild boot -L --use-remote-sudo --fast --flake .
sudo reboot
```


## Configuration options

Packages search - https://search.nixos.org/packages

NixOS - https://search.nixos.org/options

home-manager - https://nix-community.github.io/home-manager/options.html


## Build ISO image

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage
ls -l ./result/iso
````
