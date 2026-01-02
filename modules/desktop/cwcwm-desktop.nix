{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.cwcwm.nixosModules.cwc
  ];

  programs.cwc.enable = true;
}