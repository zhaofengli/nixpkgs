{ lib, stdenv, fetchFromGitHub, cmake, openssl }:

stdenv.mkDerivation rec {
  pname = "s2n-tls";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "aws";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ab3bv1jwcrr7b0hf7mpz8h1cl7jsmwhvabqr3340m7wmkpkdmmn";
  };

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [ openssl ]; # s2n-config has find_dependency(LibCrypto).

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "C99 implementation of the TLS/SSL protocols";
    homepage = "https://github.com/aws/s2n-tls";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ orivej ];
  };
}
