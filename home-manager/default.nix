{ config, pkgs, lib, host, ... }:
let
  cb14Packages = {
    home.packages = with pkgs; [
      android-tools
      antigravity
    ];
  };

  dotfiles = lib.mkMerge [
    {
      home.stateVersion = "24.05";
    }
    (if host == "cb14" then cb14Packages
    else if host == "deck" || host == "emerald" then ./development-packages.nix
    else {})
    # ./chrome.nix
    ./home-files.nix
    ./theme.nix
    ./xdg.nix
  ];
in
{
  home-manager = {
    extraSpecialArgs = { inherit host; };
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

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];


}
