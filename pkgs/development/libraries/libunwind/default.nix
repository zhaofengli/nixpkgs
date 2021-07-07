{ stdenv, lib, fetchurl, fetchpatch, autoreconfHook, xz, coreutils }:

stdenv.mkDerivation rec {
  pname = "libunwind";
  version = "1.5.0";

  src = fetchurl {
    url = "mirror://savannah/libunwind/${pname}-${version}.tar.gz";
    sha256 = "05qhzcg1xag3l5m3c805np6k342gc0f3g087b7g16jidv59pccwh";
  };

  patches = [
    # RISC-V support
    (fetchpatch {
      url = "https://github.com/zhaofengli/libunwind/commit/2abe45510f57e62651e3980d2a3c972c678a2eab.patch";
      sha256 = "1jrlr7wnr989ppci1j2ldmwpz1v43lazks2hsic4v727gq7qpww9";
    })
    (fetchpatch {
      url = "https://github.com/zhaofengli/libunwind/commit/a2e53182ae351f5075796b2faef767b17f31f510.patch";
      sha256 = "15qwkmikz3k4h526prcsg68xl7k0yx4lc0x4vrmi0a71p5gdsy5a";
    })
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isMusl ''
    substituteInPlace configure.ac --replace "-lgcc_s" "-lgcc_eh"
  '';

  nativeBuildInputs = [ autoreconfHook ];

  outputs = [ "out" "dev" "devman" ];

  # Without latex2man, no man pages are installed despite being
  # prebuilt in the source tarball.
  configureFlags = [ "LATEX2MAN=${coreutils}/bin/true" ];

  propagatedBuildInputs = [ xz ];

  postInstall = ''
    find $out -name \*.la | while read file; do
      sed -i 's,-llzma,${xz.out}/lib/liblzma.la,' $file
    done
  '';

  doCheck = false; # fails

  meta = with lib; {
    homepage = "https://www.nongnu.org/libunwind";
    description = "A portable and efficient API to determine the call-chain of a program";
    maintainers = with maintainers; [ orivej ];
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
