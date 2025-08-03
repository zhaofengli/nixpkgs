{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  tcl,
  tclPackages,
}:

tcl.mkTclDerivation rec {
  pname = "tcllauncher";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "flightaware";
    repo = "tcllauncher";
    rev = "v${version}";
    hash = "sha256-BVrsoczKeBBoM1Q3v6EJY81QwsX6xbUqFkcBb482WH4=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [ tclPackages.tclx ];

  meta = with lib; {
    description = "A launcher program for Tcl applications";
    homepage = "https://github.com/flightaware/tcllauncher";
    license = licenses.bsd3;
    maintainers = with maintainers; [ zhaofengli ];
    platforms = platforms.unix;
  };
}
