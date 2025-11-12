{ config, lib, ... }:

let
  chromePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/b3b96cb5f1ad0eab49d147a69b6fe57e584f08ff.tar.gz";
    sha256 = "05x2lbgk5p2vy74d25xlzh3j6m4c1d8mh4fdqzibd3h28nq0k3dz";
  }) {
    system = config.nixpkgs.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  options = {
    services.googleChrome.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Google Chrome (from pinned nixpkgs commit b3b96cb5f1ad0eab49d147a69b6fe57e584f08ff).";
    };
  };

  config = lib.mkIf config.services.googleChrome.enable {
    environment.systemPackages = [
      chromePkgs.google-chrome
    ];
  };
}