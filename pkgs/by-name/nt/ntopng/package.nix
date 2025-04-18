{
  lib,
  stdenv,
  autoreconfHook,
  curl,
  expat,
  fetchFromGitHub,
  git,
  json_c,
  libcap,
  libmaxminddb,
  libmysqlclient,
  libpcap,
  libsodium,
  ndpi,
  net-snmp,
  openssl,
  pkg-config,
  rdkafka,
  gtest,
  rrdtool,
  hiredis,
  sqlite,
  which,
  zeromq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ntopng";
  version = "6.2";

  src = fetchFromGitHub {
    owner = "ntop";
    repo = "ntopng";
    tag = finalAttrs.version;
    hash = "sha256-8PG18mOV/6EcBpKt9kLyI40OLDnpnc2b4IUu9JbK/Co=";
    fetchSubmodules = true;
  };

  preConfigure = ''
    substituteInPlace Makefile.in \
      --replace "/bin/rm" "rm"
  '';

  nativeBuildInputs = [
    autoreconfHook
    git
    pkg-config
    which
  ];

  buildInputs = [
    curl
    expat
    json_c
    libcap
    libmaxminddb
    libmysqlclient
    libpcap
    gtest
    hiredis
    libsodium
    net-snmp
    openssl
    rdkafka
    rrdtool
    sqlite
    zeromq
  ];

  autoreconfPhase = "bash autogen.sh";

  configureFlags = [
    "--with-ndpi-includes=${ndpi}/include/ndpi"
    "--with-ndpi-static-lib=${ndpi}/lib/"
  ];

  preBuild = ''
    sed -e "s|\(#define CONST_BIN_DIR \).*|\1\"$out/bin\"|g" \
        -e "s|\(#define CONST_SHARE_DIR \).*|\1\"$out/share\"|g" \
        -i include/ntop_defines.h
  '';

  # Upstream build system makes
  # $out/share/ntopng/httpdocs/geoip/README.geolocation.md a dangling symlink
  # to ../../doc/README.geolocation.md. Copying the whole doc/ tree adds over
  # 70 MiB to the output size, so only copy the files we need for now.
  # (Ref. noBrokenSymlinks.)
  postInstall = ''
    mkdir -p "$out/share/ntopng/doc"
    cp -r doc/README.geolocation.md "$out/share/ntopng/doc/"
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "High-speed web-based traffic analysis and flow collection tool";
    homepage = "https://www.ntop.org/products/traffic-analysis/ntop/";
    changelog = "https://github.com/ntop/ntopng/blob/${finalAttrs.version}/CHANGELOG.md";
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ bjornfor ];
    mainProgram = "ntopng";
  };
})
