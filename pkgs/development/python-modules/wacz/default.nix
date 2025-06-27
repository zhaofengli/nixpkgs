{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  black,
  boilerpy3,
  cdxj-indexer,
  click,
  frictionless,
  jsonlines,
  pytest-cov,
  pyyaml,
  shortuuid,
  typer,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "wacz";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "webrecorder";
    repo = "py-wacz";
    rev = "v${version}";
    hash = "sha256-bGY6G7qBAN1Vu+pTNqRG0xh34sR62pMhQFHFGlJaTPQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pytest-runner" ""
  '';

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    black
    boilerpy3
    cdxj-indexer
    click
    frictionless
    jsonlines
    pytest-cov
    pyyaml
    shortuuid
    typer
  ];

  optional-dependencies = {
    # signing = [
    #   authsign # not packaged
    # ];
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  disabledTests = [
    # authsign is not packaged
    "test_verify_signed"
  ];

  pythonImportsCheck = [
    "wacz"
  ];

  dontCheckRuntimeDeps = true;

  meta = {
    description = "Utility for working with web archive data using the WACZ format specification";
    homepage = "https://github.com/webrecorder/py-wacz";
    changelog = "https://github.com/webrecorder/py-wacz/blob/${src.rev}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zhaofengli ];
    mainProgram = "wacz";
  };
}
