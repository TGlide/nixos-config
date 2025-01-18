{
  stdenv,
  nodejs,
  # This is pinned as { pnpm = pnpm_9; }
  pnpm,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tailwindcss-language-server";
  version = "0.12.6";

  src = fetchFromGitHub {
    owner = "tailwindlabs";
    repo = "tailwindcss-intellisense";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-rBUDTkTqwFdYevnCw4atjRtDSC+dx9C1Tubawa/qa+w=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  pnpmWorkspaces = ["@tailwindcss/language-server..."];

  pnpmDeps = pnpm.fetchDeps {
    inherit
      (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    hash = "sha256-wR2VJRmb/ZnEDnKz6BkyhUdQJh3aZoUZtE24UM+nMcU=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm --filter "@tailwindcss/language-server" build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/tailwindcss-language-server}
    cp -r {packages,node_modules} $out/lib/tailwindcss-language-server
    ln -s $out/lib/tailwindcss-language-server/packages/tailwindcss-language-server/bin/tailwindcss-language-server $out/bin/tailwindcss-language-server

    chmod +x $out/bin/tailwindcss-language-server

    runHook postInstall
  '';
})
