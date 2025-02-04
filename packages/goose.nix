{
  lib,
  stdenv,
  fetchurl,
  bash,
}:
stdenv.mkDerivation rec {
  pname = "goose";
  version = "stable";

  src = fetchurl {
    url = "https://github.com/block/goose/releases/download/${version}/download_cli.sh";
    sha256 = "043910a93ib7bgisni0m3h37798axrpsbrmdlc43hga6z3a1ywfz";
  };

  nativeBuildInputs = [bash];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/goose-installer
    chmod +x $out/bin/goose-installer
    CONFIGURE=false $out/bin/goose-installer CONFIGURE
    mv ~/.local/bin/goose $out/bin/
    rm $out/bin/goose-installer
  '';

  meta = with lib; {
    description = "Goose CLI tool";
    homepage = "https://github.com/block/goose";
    license = licenses.mit; # Adjust based on actual license
    platforms = platforms.all;
  };
}
