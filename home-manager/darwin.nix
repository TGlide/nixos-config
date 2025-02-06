{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.username = lib.mkForce "thomasglopes";
  home.homeDirectory = lib.mkForce "/Users/thomasglopes";

  home.packages = with pkgs; [
    # LSPs
  ];

  programs.fish.functions = {
    modify_nix = ''
      cd ~/nixos-config/
      nvim
    '';
    rebuild_nix = ''
      nix run nix-darwin -- switch --flake ~/nixos-config/flake.nix
    '';
  };
}
