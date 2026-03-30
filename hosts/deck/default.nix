{ config, ... }:

{
  imports = [
    ./configuration.nix
  ];

  config = {
    home-manager.users.luiz = {
      imports = [
        ./home.nix
        ../../modules/music/default.nix
      ];
    };
  };
}
