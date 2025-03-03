{ stdenv }: 
let
  BCL110 = ./BCL110.ppd;
  raster_zpl = ./raster-zpl;
in
  stdenv.mkDerivation rec {
    name = "BCL110-${version}";
    version = "1.0";

    src = ./.;

    installPhase = ''
      mkdir -p $out/share/cups/model/
      cp ${BCL110} $out/share/cups/model/

      mkdir -p $out/lib/cups/filter/
      cp ${raster_zpl} $out/lib/cups/filter/raster-zpl
    '';
  }
