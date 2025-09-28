# modules/debian-container.nix
{ config, lib, pkgs, ... }:

{
  # Enable containers
  boot.enableContainers = true;

  containers.debian-trixie = {
    autoStart = false;  # Set to true if you want it to start automatically
    enableTun = true;   # Enable TUN/TAP for networking
    privateNetwork = false;  # Share host network (easier setup)
    
    # Optional: Set resource limits
    # allowedDevices = [
    #   { node = "/dev/null"; modifier = "rw"; }
    #   { node = "/dev/zero"; modifier = "rw"; }
    # ];

    config = { config, pkgs, ... }: {
      system.stateVersion = "24.05";
      
      # Basic system configuration
      time.timeZone = "America/Chicago";
      i18n.defaultLocale = "en_US.UTF-8";
      
      # Create user
      users.users.debian = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "debian";  # Change this!
      };
      
      # Enable sudo without password for convenience
      security.sudo.wheelNeedsPassword = false;
      
      # Install essential packages
      environment.systemPackages = with pkgs; [
        vim
        git
        curl
        wget
        htop
        tree
        python3
        python3Packages.pip
        python3Packages.virtualenv
      ];
      
      # Enable SSH
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
      
      # Networking
      networking = {
        useHostResolvConf = lib.mkForce false;
        nameservers = [ "8.8.8.8" "8.8.4.4" ];
      };
    };
  };

  # Helper scripts for container management
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "debian-container" ''
      case "$1" in
        start)
          sudo nixos-container start debian-trixie
          echo "Container started. Use 'debian-container shell' to access it."
          ;;
        stop)
          sudo nixos-container stop debian-trixie
          echo "Container stopped."
          ;;
        shell)
          sudo nixos-container root-shell debian-trixie
          ;;
        status)
          sudo nixos-container status debian-trixie
          ;;
        *)
          echo "Usage: debian-container {start|stop|shell|status}"
          echo "  start  - Start the container"
          echo "  stop   - Stop the container"
          echo "  shell  - Get a shell in the container"
          echo "  status - Show container status"
          ;;
      esac
    '')
  ];
}