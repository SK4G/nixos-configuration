{ config, pkgs, ... }:

{
  # environment.variables = {
  #   EDITOR = "nano";
  #   BROWSER = "google-chrome-stable";
  # };

  environment.sessionVariables = rec {
    GTK_USE_PORTAL  = 0;  # Fixes slow launch of GTK apps
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.bin";
    PATH = [ 
      "${XDG_BIN_HOME}"
    ];
  };	
}
