{ lib
, stdenv
, fetchurl
, curl
, unzip
, ncurses5
, autoPatchelfHook
}:
let
  version = "10.2.1003";
  versionUri = builtins.replaceStrings ["."] ["_"] version;

  sources = {
    "x86_64-linux" = {
      url = "https://www.passmark.com/downloads/pt_linux_x64_${versionUri}.zip";
      hash = "sha256-H9IusuDkyFRD4LVcIF5eGVsIeYgzCkCNJR+eZagqQOc=";
    };
    "aarch64-linux" = {
      url = "https://www.passmark.com/downloads/pt_linux_arm64_${versionUri}.zip";
      hash = "sha256-v7qxVR2eM5w4178J3+sI2Tpi5SEteQQbabXgin6RUUk=";
    };
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "passmark-performancetest";

  src = fetchurl (sources.${stdenv.system});

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib
    curl
    ncurses5
  ];

  unpackPhase = "unzip $src";

  installPhase = ''
    mkdir -p $out/bin
    cp PerformanceTest/pt_linux_x64 $out/bin/performancetest
  '';

  meta = with lib; {
    description = "A software tool that allows everybody to quickly assess the performance of their computer and compare it to a number of standard 'baseline' computer systems.";
    homepage = "https://www.passmark.com";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ neverbehave ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "performancetest";
  };
}
