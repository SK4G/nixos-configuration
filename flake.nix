{
  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nixpkgs = {
      follows = "chaotic/nixpkgs";
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    jovian = {
      follows = "chaotic/jovian";
      url = "github:Jovian-Experiments/Jovian-NixOS";
    };

    yuzu.url = "git+https://codeberg.org/K900/yuzu-flake";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cachix = {
      url = "github:cachix/cachix";
    };

    disko = {
      url = "github:nix-community/disko/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs: {
    nixosConfigurations = builtins.listToAttrs (builtins.map
      ({ host
       , name ? host
       , configuration ? "configuration.nix"
       , system ? "x86_64-linux"
       , nixpkgs ? inputs.nixpkgs
       , extraModules ? [ ]
       , ... }: nixpkgs.lib.nameValuePair name (
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            # Configure disko module
            inputs.disko.nixosModules.disko

            # Configure home-manager module
            inputs.home-manager.nixosModules.home-manager

            # Common modules
            ./modules/nixosModules

            ./home-manager

            ./modules/flakes.nix
            ./modules/locale.nix
            ./modules/networkd.nix
            # ./modules/sysctl.nix
            ./home-manager/tools.nix
            ./modules/users.nix
            
            {
              nix.settings = {
                download-buffer-size = 524288000;
                substituters = [
                  "https://0uptime.cachix.org"
                ];
                trusted-public-keys = [
                  "0uptime.cachix.org-1:ctw8yknBLg9cZBdqss+5krAem0sHYdISkw/IFdRbYdE="
                ];
              };
            }

          ] ++ nixpkgs.lib.optional (configuration != null)
              # Use host configuration
              ./hosts/${host}/${configuration}
            ++ extraModules;
        })
      )
      # Systems list
      [
        {
          host = "cb14";
          extraModules = [
            ./modules/desktop
            ./modules/desktop/awesome.nix
            # ./modules/desktop/gnome.nix
            # ./modules/desktop/plasma5.nix
            # ./modules/desktop/hyprland.nix

            ./modules/hardware/hw-acceleration-amd.nix
            ./modules/bluetooth.nix
            ./modules/desktop/desktop-packages.nix
            # ./home-manager/development-packages.nix
            ./modules/office.nix
            ./modules/printers
            ./modules/laptop.nix
          ];
        }
        {
          host = "deck";
          extraModules = [
            inputs.jovian.nixosModules.jovian
            inputs.chaotic.nixosModules.default

            ./modules/jovian.nix

            ./modules/hardware/hw-acceleration-amd.nix
            ./modules/hardware/1440p-monitor.nix
            ./modules/desktop
            ./modules/video-editing.nix
            # ./home-manager/kodi.nix

            #./home-manager/development-packages.nix
            ./modules/gaming.nix
            ./modules/office.nix
            # ./modules/printers
            ./modules/printers
            ./modules/polkit.nix
            # ./modules/power-settings.nix
            ./modules/virt-manager.nix
            ./modules/waydroid.nix
          ];
        }
        {
          host = "iso";
          configuration = null;
          extraModules = [
            ({ config, ... }: {
              boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
            })

            ./modules/desktop
            ./modules/desktop/plasma5.nix
            # ./modules/desktop/gnome.nix
            ./modules/autoLogin.nix
            ./modules/iso.nix
          ];
        }
        {
          host = "jovian-iso";
          configuration = null;
          extraModules = [
            inputs.jovian.nixosModules.jovian

            ./modules/jovian.nix
            ./modules/iso.nix

            ./modules/autoLogin.nix
          ];
        }
      ]
    );
  };
}
