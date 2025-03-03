{ pkgs, lib, ... }:
{
  programs.bat.enable = true;
  programs.bat.config = {
    theme = "Monokai Extended";
  };

  programs.dircolors.enable = true;

  programs.fzf.enable = true;
  programs.fzf.historyWidgetOptions = [
    "--no-extended"
    "--exact"
    "--no-sort"
    "--scheme=history"
  ];
}
