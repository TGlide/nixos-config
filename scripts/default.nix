# In scripts/default.nix:
{pkgs ? import <nixpkgs> {}}: let
  # Helper function to create a script derivation
  mkScript = name: script: pkgs.writeScriptBin name (builtins.readFile script);

  # List all your scripts here
  scripts = {
    change-media-output = mkScript "change-media-output" ./change-media-output.sh;
  };
in {
  # Export all scripts
  inherit scripts;

  # Create a package that includes all scripts
  allScripts = pkgs.symlinkJoin {
    name = "custom-scripts";
    paths = builtins.attrValues scripts;
  };
}
