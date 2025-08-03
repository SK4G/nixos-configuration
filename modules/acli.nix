{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      acli = super.callPackage ({
        stdenv,
        fetchurl,
        makeWrapper,

      }: stdenv.mkDerivation rec {
        name = "acli-${version}";
        version = "latest";
        
        src = fetchurl {
          url = "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli";
          sha256 = "8mHTHBQToRFrFHmCSHPt6g+3UDiaVgLMZfWHipGF444=";
        };
        
        nativeBuildInputs = [ makeWrapper ];
        
        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;
        
        installPhase = ''
          install -Dm755 $src $out/bin/acli
        '';
        
        meta = with super.lib; {
          description = "Atlassian Command Line Interface";
          homepage = "https://atlassian.com";
          license = licenses.asl20;
          platforms = platforms.linux;
          maintainers = with maintainers; [ ];
        };
      }) {};
    })
  ];
  environment.systemPackages = with pkgs; [
  acli
  ];
}