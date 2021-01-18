{ lib, fetchFromGitHub, buildPythonPackage, isPy3k,
isodate, lxml, xmlsec, defusedxml, freezegun }:

buildPythonPackage rec {
  pname = "python3-saml";
  version = "1.10.0";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "onelogin";
    repo = "python3-saml";
    rev = "v${version}";
    sha256 = "1wh8rhjmjsl7y6fknzhrwwr69say68m11fqmywvxijk9kpn6qavl";
  };

  propagatedBuildInputs = [
    isodate lxml xmlsec defusedxml
  ];

  checkInputs = [ freezegun ];

  meta = with lib; {
    description = "OneLogin's SAML Python Toolkit for Python 3";
    homepage = "https://github.com/onelogin/python3-saml";
    license = licenses.mit;
    maintainers = with maintainers; [ zhaofengli ];
  };
}
