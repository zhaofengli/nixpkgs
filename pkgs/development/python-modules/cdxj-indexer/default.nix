{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  warcio,
  surt,
  idna,
  py3amf,
  multipart,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "cdxj-indexer";
  version = "1.4.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "webrecorder";
    repo = "cdxj-indexer";
    rev = "v${version}";
    hash = "sha256-E3b/IfjngyXhWvRYP9CkQGvBFeC8pAm4KxZA9MwOo4s=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    warcio
    surt
    idna
    py3amf
    multipart
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "cdxj_indexer"
  ];

  # Upstream specifies idna<3.0, but the issue that triggered the pinning
  # has since been fixed: <https://github.com/webrecorder/cdxj-indexer/issues/26>
  #
  # Furthermore, we do not enable the signing feature at the moment.
  dontCheckRuntimeDeps = true;

  meta = {
    description = "CDXJ Indexing of WARC/ARCs";
    homepage = "https://github.com/webrecorder/cdxj-indexer";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ zhaofengli ];
    mainProgram = "cdxj-indexer";
  };
}
