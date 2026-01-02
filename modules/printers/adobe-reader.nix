{ config, lib, pkgs, ... }:

let
  adobePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4e81db679e8776af71f664fac129b10ae703ceb6.tar.gz";
    sha256 = "0a09s62hmjjwi43bqkd1n0p4hsg73jphrj0vq9bab4avkax96zi3";
  }) {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "adobe-reader-9.5.5" ];
    };
  };
in {
  options = {
    services.adobeReader.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Adobe Reader (from pinned nixpkgs commit 4e81db679e8776af71f664fac129b10ae703ceb6).";
    };
  };

  config = lib.mkIf config.services.adobeReader.enable {
    environment.systemPackages = [
      adobePkgs.adobe-reader
    ];
  };
}
