{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "tailwind-language-server";
  version = "0.12.6";

  src = fetchFromGitHub {
    owner = "tailwindlabs";
    repo = "tailwindcss-intellisense";
    rev = "${version}";
    sha256 = "g4AZ1+Jq6G5F3jq2jVSOkfR1fVITGgNTGb1YRFLzcAQ=";
  };

  npmDepsHash = "sha256-YsLfsnEUk98yH4KmQQsQn2Xg4U9fTDhTF/VwWxtxMKo=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = ["--ignore-scripts"];

  NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    homepage = "https://github.com/microsoft/inshellisense";
    license = licenses.mit;
    maintainers = with maintainers; [trevorwhitney];
  };
}
