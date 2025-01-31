{pkgs ? import <nixpkgs> {}}:
pkgs.symlinkJoin {
  name = "custom-scripts";
  paths = let
    # Read all files in the current directory
    files = builtins.readDir ./.;
    # Filter out default.nix and non-.sh files
    scriptFiles =
      builtins.filter
      (name: builtins.match ".*\\.sh$" name != null)
      (builtins.attrNames files);
    # Create a script for each .sh file
    makeScript = name:
      pkgs.runCommand name {} ''
        mkdir -p $out/bin
        cp ${pkgs.writeScript name (builtins.readFile ./${name})} $out/bin/${builtins.substring 0 (builtins.stringLength name - 3) name}
        chmod +x $out/bin/*
      '';
  in
    map makeScript scriptFiles;
}
