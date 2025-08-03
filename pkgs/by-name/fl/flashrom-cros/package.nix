{ lib, stdenv, fetchgit, pkg-config, meson, ninja
, libftdi1
, libusb1
, pciutils
, cmocka
}:

stdenv.mkDerivation rec {
  pname = "flashrom-cros";
  version = "R110-15278.B";

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromiumos/third_party/flashrom";
    rev = "bc6a1b933141acd74951f4992b7fcb9d8b060e12";
    hash = "sha256-GsUuASmLkEXPU9d2eyBpoXTo33MvQQ6trGvTiIJeNv0=";
  };

  nativeBuildInputs = [
    pkg-config meson ninja
  ] ++ checkInputs;

  buildInputs = [
    libftdi1 libusb1 pciutils
  ];

  checkInputs = [
    cmocka
  ];
}
