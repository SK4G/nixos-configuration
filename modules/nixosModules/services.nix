{ pkgs, config, ... }:

{
  services = {
    qdrant.enable = true;
  };
}
