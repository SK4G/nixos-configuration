{pkgs, ...}: {
  # hardware.printers = {
  #   ensurePrinters = [
  #     # {
  #     #   name = "HP_DeskJet_2800_series_276B08";
  #     #   description = "HP DeskJet 2800 series";
  #     #   location = "Local Printer";
  #     #   deviceUri = "dnssd://HP%20DeskJet%202800%20series%20%5B276B08%5D._ipp._tcp.local/?uuid=5e8778d6-018e-48ec-8838-c8cf40170b95";
  #     #   model = "drv:///hp/hpcups.drv/hp-Deskjet_2800_series.ppd";
  #     #   ppdOptions = {
  #     #     PageSize = "A4";
  #     #   };
  #     # }

  #     {
  #       name = "BCL_D1102";
  #       description = "BCL BCL1102 Label Printer";
  #       location = "Local Printer";
  #       # deviceUri = "dnssd://BCL%20D1102%20%40%20DietPi._ipp._tcp.local/";
  #       # deviceUri = "dnssd://BCL%20D1102%20%40%20DietPi._printer._tcp.local/";
  #       deviceUri = "ipp://192.168.1.65:631/printers/BCL_D1102";
  #       model = "wgfm1k09rdynhzzcywkv2h6ncar6kd69-BCL110.ppd";
  #       ppdOptions = {
  #         media = "om_small-photo_100x150mm";
  #       };
  #     }
  #   ];
  #   ensureDefaultPrinter = "BCL_D1102";
  # };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # services.printing = {
  #   enable = true;
  #   browsing = true;
  #   drivers = [
  #     (pkgs.callPackage ./BCL110.nix {})
  #   ];
  # };
  
  environment.systemPackages = with pkgs; [
    adobe-reader
    # gnome.simple-scan
    # gutenprint
    # libxcrypt
    pdfarranger
    pdftk
    system-config-printer

    ### network discovery
    # openresolv

    ### filters
    cups-filters
    # foomatic-db-engine
    # foomatic-db-ppds
    # foomatic-db-ppds-withNonfreeDb
    ghostscript

    ### drivers
    brlaser
    gutenprint
  ];
  
  nixpkgs.config.permittedInsecurePackages = [
    "adobe-reader-9.5.5"
  ];

}
