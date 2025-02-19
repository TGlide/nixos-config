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
    url = "https://desktop.docker.com/linux/main/amd64/165256/docker-desktop-amd64.deb?utm_source=nixpkgs";
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

    # Debug: List all files to find the actual binary
      echo "Contents of package:"
      find . -type f -executable

        mkdir -p $out/{bin,lib,share}
        cp -r usr/* $out/
        cp -r opt/docker-desktop/* $out/lib/

        # Create wrapper for the main binary
        makeWrapper $out/lib/docker-desktop $out/bin/docker-desktop \
          --prefix PATH : $out/bin \
          --prefix LD_LIBRARY_PATH : $out/lib

        # Ensure the binary is executable
        chmod +x $out/bin/docker-desktop

        runHook postInstall
  '';
}
