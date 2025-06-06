{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  xorg,
  dbus,
  gcc,
}:
stdenv.mkDerivation rec {
  pname = "goose";
  version = "stable";

  src = fetchurl {
    url = let
      platform =
        if stdenv.isDarwin
        then "apple-darwin"
        else "unknown-linux-gnu";
      arch =
        if stdenv.isAarch64
        then "aarch64"
        else "x86_64";
    in "https://github.com/block/goose/releases/download/${version}/goose-${arch}-${platform}.tar.bz2";
    sha256 =
      if stdenv.isDarwin
      then "sha256-ItdEdHU5Q6L/iJsYtOstBcbkfpvwx7Bfb6vi8w2cfJ4="
      else "NHvFCEKkGy3kSrMBZu9ufSWU04JpVmnwnmiiwMnEU80=";
  };

  nativeBuildInputs = lib.optionals stdenv.isLinux [autoPatchelfHook];
  buildInputs = lib.optionals stdenv.isLinux [
    xorg.libxcb
    dbus
    gcc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 goose $out/bin/goose
  '';

  meta = with lib; {
    description = "Goose CLI tool";
    homepage = "https://github.com/block/goose";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
