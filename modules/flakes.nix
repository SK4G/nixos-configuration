{ config, pkgs, lib, inputs, ... }:
let
  exportedInputs = lib.filterAttrs
    (name: value: name != "self")
    inputs;
in
{
  environment.etc = lib.mapAttrs'
    (name: value: { name = "nix/channels/${name}"; value = { source = value.outPath; }; })
    exportedInputs;

  nix.nixPath = lib.mkForce (lib.mapAttrsToList
    (name: value: "${name}=/etc/nix/channels/${name}")
    exportedInputs);

  nix.registry = lib.mapAttrs
    (name: value: { flake = value; })
    exportedInputs;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
