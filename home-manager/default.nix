{ config, pkgs, lib, ... }:
let
  dotfiles = lib.mkMerge [
    {
      home.stateVersion = "24.05";
    }
    ./chrome.nix
    ./development-packages.nix
    # ./firefox.nix
    ./home-files.nix
    ./kodi.nix
    ./theme.nix
    ./xdg.nix
  ];
in
{
  home-manager = {
    users = {
      luiz = dotfiles;
      # root = dotfiles;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
  
  home-manager.backupFileExtension = "backup";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    # ohMyZsh = {
    #   enable = true;
    #   plugins = [ "git" ];
    # };
  };

  users.users.luiz.shell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;

}
