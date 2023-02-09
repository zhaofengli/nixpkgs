{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "mlat-client";
  version = "0.2.13";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "mutability";
    repo = "mlat-client";
    rev = "v${version}";
    hash = "sha256-fSjkEyE8oP9HQlZCAqCjvOchDyNpFqm8qlkMg373/kE=";
  };

  build-system = [ python3Packages.setuptools ];

  meta = with lib; {
    description = "Mode S multilateration client";
    homepage = "https://github.com/mutability/mlat-client";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ zhaofengli ];
    platforms = platforms.linux;
  };
}
