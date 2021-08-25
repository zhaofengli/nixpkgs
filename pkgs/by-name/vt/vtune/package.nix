{ stdenv, lib, fetchurl, autoPatchelfHook, wrapGAppsHook
, libarchive

, hwloc
, libndctl
, gdbm
, ncurses5
, readline
, fontconfig
, libxkbcommon
, openssl
, libkrb5
, gtk3
, glib
, gdk-pixbuf
, cairo
, pango
, icu67
, atk
, nss
, cups
, alsa-lib
, mesa
, libglvnd
, kmod
, systemdMinimal
, xorg
}:

let
  version = "2021.6.0-411";
  baseVersion = lib.head (lib.splitString "-" version);

  components = [
    { id = "intel.oneapi.lin.oneapi-common.licensing"; version = "2021.3.0-261"; }
    { id = "intel.oneapi.lin.vtune"; version = "2021.6.0-411"; }
  ];
in stdenv.mkDerivation {
  pname = "vtune";
  inherit version;

  src = fetchurl {
    url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/18012/l_oneapi_vtune_p_2021.6.0.411_offline.sh";
    sha256 = "032nwnidrfjw63yxywdgpysrarh098zg4vycbdkaldrkf7dgf7bb";
  };

  buildInputs = [
    stdenv.cc.cc.lib

    hwloc
    libndctl
    gdbm
    ncurses5
    readline
    fontconfig
    libxkbcommon
    openssl
    libkrb5
    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    icu67
    atk
    nss
    cups
    alsa-lib
    mesa
    libglvnd
    kmod
    systemdMinimal
  ] ++ (with xorg; [
    libXrandr
    libxcb
    libxshmfence
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ]);

  autoPatchelfIgnoreMissingDeps = true;

  nativeBuildInputs = [
    libarchive autoPatchelfHook
  ];

  unpackPhase = ''
    bash $src -x
    cd l_oneapi_*
  '';

  installPhase = let
    commands = map (component: "bsdtar xf packages/${component.id},v=${component.version}/cupPayload.cup --strip-components=1 -C $out/opt/intel") components;
  in ''
    mkdir -p $out/opt/intel $out/bin

    ${builtins.concatStringsSep "\n" commands}

    for executable in "vtune" "vtune-gui" "vtune-agent" "vtune-backend" "vtune-worker"; do
      ln -s $out/opt/intel/vtune/${baseVersion}/bin64/$executable $out/bin/$executable
    done
  '';

  meta = with lib; {
    description = "Performance analysis tool for x86-based machines";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ zhaofengli ];
    platforms = [ "x86_64-linux" ];
  };
}
