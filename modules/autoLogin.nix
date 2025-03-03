# For usage in installation iso
{ config, lib, pkgs, ... }: {
  # Configure autologin
  services.displayManager.autoLogin = {
    enable = true;
    user = "luiz";
  };
  # Automatically log in at the virtual consoles.
  services.getty.autologinUser = "luiz";
  # Allow log in without a password.
  users.users.luiz.initialHashedPassword = "";
  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = "";
}
