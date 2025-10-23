{ 
  lib,
  stdenv,
  fetchurl,
  makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "acli";
  version = "1.3.3-stable";

  src = fetchurl {
    url = "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli";
    sha256 = "hnEAQMtbvtTfxQt7c959EaIeKrPeLC9k3EO9Hcre9as=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    install -Dm755 $src $out/bin/acli
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Atlassian Command Line Interface";
    homepage = "https://developer.atlassian.com/cloud/acli";
    license = "";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}