{ config, pkgs, ... }:

{
  home.packages = with pkgs; [

  ];

  home.shellAliases = {
      ls = "exa --header --icons --classify";
      ll = "exa -l --header --icons --classify";
      la = "exa -a --header --icons --classify";
      hmp = "home-manager packages | sort";
  };

  # Have home-manager create and manage the config files for these shells:
  programs.bash.enable = true;
  programs.fish.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = {};
    shellAliases = {
      n-cg = "sudo nix-collect-garbage --delete-old";
    };
    sessionVariables = {};
    historyIgnore = {};
  };
}
