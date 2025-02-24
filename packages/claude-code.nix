{
  lib,
  stdenv,
  nodejs,
  fetchurl,
  makeWrapper,
}: let
  pname = "@anthropic-ai/claude-code";
  version = "0.2.8";
  # For scoped packages, we need to escape the @ in the URL
  pkgNameForUrl = "anthropic-ai/claude-code";
in
  stdenv.mkDerivation {
    name = "claude"; # Using name instead of pname for scoped packages
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/@${pkgNameForUrl}/-/claude-code-${version}.tgz";
      sha256 = "ZhIW3W2lTqNTb+upS3VUr4ojnWdgLFSkdHmH8m6p2us=";
    };

    buildInputs = [nodejs makeWrapper];

    # Simplified installation - just unpack and create a wrapper
    # This avoids running npm install, which can get stuck
    unpackPhase = ''
      mkdir -p $out
      tar -xzf $src -C $out
    '';

    installPhase = ''
      # The package directory is usually under "package"
      if [ -d "$out/package" ]; then
        cd "$out/package"
      else
        cd "$out"
      fi

      # Create bin directory
      mkdir -p $out/bin

      # Create a wrapper script for cli.mjs
      makeWrapper ${nodejs}/bin/node $out/bin/claude \
        --add-flags "$out/package/cli.mjs" \
        --set NODE_PATH "$out/package"
    '';

    meta = with lib; {
      description = "Claude CLI tool by Anthropic";
      homepage = "https://anthropic.com";
      license = licenses.unfree;
      platforms = platforms.all;
      maintainers = [];
    };
  }
