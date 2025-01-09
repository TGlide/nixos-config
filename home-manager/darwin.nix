{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.username = lib.mkForce "thomasglopes";
  home.homeDirectory = lib.mkForce "/Users/thomasglopes";


  home.packages = with pkgs; [];
}
