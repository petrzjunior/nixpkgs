{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  version = "6.4.2";
  pname = "clips";

  src = fetchurl {
    url = "mirror://sourceforge/clipsrules/CLIPS/${version}/clips_core_source_${
      builtins.replaceStrings [ "." ] [ "" ] version
    }.tar.gz";
    hash = "sha256-YIoesvxunK/zDWPWhAlfC8pxCPIpTSHub1YXQnwQRVo=";
  };

  postPatch = ''
    substituteInPlace core/makefile --replace 'gcc' '${stdenv.cc.targetPrefix}cc'
  '';

  makeFlags = [
    "-C"
    "core"
  ];

  installPhase = ''
    runHook preInstall
    install -D -t $out/bin core/clips
    install -D -t $out/lib core/libclips.a
    install -D -t $out/include core/*.h
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool for Building Expert Systems";
    mainProgram = "clips";
    homepage = "http://www.clipsrules.net/";
    longDescription = ''
      Developed at NASA's Johnson Space Center from 1985 to 1996,
      CLIPS is a rule-based programming language useful for creating
      expert systems and other programs where a heuristic solution is
      easier to implement and maintain than an algorithmic solution.
    '';
    license = licenses.publicDomain;
    maintainers = [ maintainers.league ];
    platforms = platforms.unix;
  };
}
