{ lib, stdenv, fetchFromGitHub, pkgs, nodejs, nodePackages }:

let
  version = "1.27.1";

  src = fetchFromGitHub {
    owner = "nttgin";
    repo = "BGPalerter";
    rev = "v${version}";
    sha256 = "1jskggyd67hvmqhwnx2vzw871wbhzf58y6z2dq22r8s9hzapiqrd";
  };

  devPackages = (import ./node-dev-packages.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  });
  devShell = (devPackages.shell.override {
    inherit src;
    nativeBuildInputs = [ nodePackages.node-gyp-build ];
  }).nodeDependencies;

  runPackages = (import ./node-packages.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  });
  runShell = (devPackages.shell.override {
    inherit src;
    nativeBuildInputs = [ nodePackages.node-gyp-build ];
  }).nodeDependencies;
in stdenv.mkDerivation {
  name = "bgpalerter";
  inherit src version;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildPhase = ''
    runHook preBuild

    ln -s ${devShell}/lib/node_modules node_modules
    export PATH="${devShell}/bin:$PATH"

    babel index.js -d dist
    babel src -d dist/src
    cp package.json dist/package.json

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/usr/share
    cp -r dist $out/usr/share/bgpalerter

    makeWrapper '${nodejs}/bin/node' "$out/bin/bgpalerter" \
    --set NODE_PATH "${runShell}/lib/node_modules" \
    --add-flags "$out/usr/share/bgpalerter/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Self-configuring BGP monitoring tool";
    homepage = "https://github.com/nttgin/BGPalerter";
    license = licenses.bsd3;
    maintainers = with maintainers; [ zhaofengli ];
  };
}
