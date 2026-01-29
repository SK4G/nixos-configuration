{ config, pkgs, ... }:

{
  programs.kodi = {
    enable = true;
    # Use kodi without problematic inputstream-adaptive package
    package = pkgs.kodi;
  };
}