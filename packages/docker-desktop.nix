{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dpkg,
  libseccomp,
  libcap_ng,
  alsa-lib,
  nss,
  gtk3,
  mesa,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "docker-desktop";
  version = "4.34.0";
  revision = 165256;

  src = fetchurl {
    url = "https://desktop.docker.com/linux/main/amd64/${toString revision}/${pname}-amd64.deb?utm_source=nixpkgs";
    sha256 = "sha256-qFepUUftBj7GgM2ZIiY8GjhAy16RRPjg2oW1pgbSYYk=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libseccomp
    libcap_ng
    alsa-lib
    nss
    gtk3
    mesa
  ];

  sourceRoot = ".";
  unpackPhase = ''
    ${dpkg}/bin/dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';
}
