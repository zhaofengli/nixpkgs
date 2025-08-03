{
  lib,
  stdenv,
  fetchFromGitHub,
  tcl,
  tcllauncher,
  tclPackages,
  openssl,
  which,
  coreutils,
  iproute2,
  dump1090-fa,
  mlat-client,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "piaware";
  version = "10.2";

  src = fetchFromGitHub {
    name = "piaware-v${finalAttrs.version}-source";
    owner = "flightaware";
    repo = "piaware";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pt8jrcD1UJbCvzCnbwvtf+wy+w+hka3xyzXB4L12TiQ=";
  };

  buildInputs = [
    tcl
    tcllauncher
    tclPackages.tcllib
    tclPackages.tcltls
  ];

  nativeBuildInputs = [
    tcl.tclPackageHook
    openssl
    which
  ];

  postPatch = ''
    # uname: Used to generate informational message (hardcoded)
    # ip: Used to obtain MAC address for unique feeder ID (hardcoded)
    # netstat: Used to determine whether helper processes are listening (from PATH)
    find . -type f -name '*.tcl' -print0 | xargs -0 \
      sed -i \
        -e 's|/bin/uname|${coreutils}/bin/uname|g' \
        -e 's|/sbin/ip|${iproute2}/bin/ip|g' \
        -e "s|/usr/lib/piaware/helpers|$out/lib/piaware/helpers|g"
  '';

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    ln -s ${dump1090-fa}/bin/faup1090 $out/lib/piaware/helpers/faup1090
    ln -s ${mlat-client}/bin/fa-mlat-client $out/lib/piaware/helpers/fa-mlat-client

    # HACK for tcllauncher
    while IFS= read -d "" executable; do
      if [ -d "$out/lib/$executable" ]; then
        ln -s "$out/lib/$executable" "$out/lib/.$executable-wrapped"
      fi
    done < <(find "$out/bin" -executable -type f -printf "%f\0")
  '';

  meta = with lib; {
    description = "Client-side package and programs for forwarding ADS-B data to FlightAware";
    homepage = "https://github.com/flightaware/piaware";
    license = licenses.bsd2;
    platforms = platforms.unix;
    maintainers = with maintainers; [ zhaofengli ];
  };
})
