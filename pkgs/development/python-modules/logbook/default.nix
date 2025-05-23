{
  lib,
  brotli,
  buildPythonPackage,
  cython,
  execnet,
  fetchFromGitHub,
  jinja2,
  pytestCheckHook,
  pytest-rerunfailures,
  pythonOlder,
  pyzmq,
  redis,
  setuptools,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "logbook";
  version = "1.8.0";
  format = "setuptools";

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "getlogbook";
    repo = "logbook";
    tag = version;
    hash = "sha256-SpM7LQVcQ9eJ88QDpq/3rq04jr0zrrrQuTeqtz9xsng=";
  };

  nativeBuildInputs = [
    cython
    setuptools
  ];

  optional-dependencies = {
    execnet = [ execnet ];
    sqlalchemy = [ sqlalchemy ];
    redis = [ redis ];
    zmq = [ pyzmq ];
    compression = [ brotli ];
    jinja = [ jinja2 ];
    all = [
      brotli
      execnet
      jinja2
      pyzmq
      redis
      sqlalchemy
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-rerunfailures
  ] ++ lib.flatten (builtins.attrValues optional-dependencies);

  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;

  pythonImportsCheck = [ "logbook" ];

  disabledTests = [
    # Test require Redis instance
    "test_redis_handler"
  ];

  meta = with lib; {
    description = "Logging replacement for Python";
    homepage = "https://logbook.readthedocs.io/";
    changelog = "https://github.com/getlogbook/logbook/blob/${version}/CHANGES";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
