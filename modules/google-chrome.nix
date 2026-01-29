{ config, lib, pkgs, ... }:

let
  chromePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/b3b96cb5f1ad0eab49d147a69b6fe57e584f08ff.tar.gz";
    sha256 = "1pr30fgx1rli4071fl569nar15sciqcrz88kj0a9prni6qyd3i6y";
  }) {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  options = {
    services.googleChrome.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Google Chrome (from pinned nixpkgs commit b3b96cb5f1ad0eab49d147a69b6fe57e584f08ff).";
    };
  };

  config = lib.mkIf config.services.googleChrome.enable {
    environment.systemPackages = [
      chromePkgs.google-chrome
    ];
  };
}