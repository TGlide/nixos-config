{
  pkgs,
  lib,
  unstable,
  ...
}: {
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.username = lib.mkForce "thomasglopes";
  home.homeDirectory = lib.mkForce "/Users/thomasglopes";

  home.packages = with pkgs; [
    # Terminal tools
    yazi
    unstable.aerospace
  ];

  programs.fish.functions = {
    modify_nix = ''
      cd ~/nixos-config/
      nvim
    '';
    rebuild_nix = ''
      nix run nix-darwin -- switch --flake ~/nixos-config/
    '';
  };

  programs.ssh = {
    enable = true;
    # Optional: Add specific host configurations
    extraConfig = ''
      Host vps
      	HostName 37.221.194.92
      	User root
      	IdentityFile ~/.ssh/vps

      Host github.com
      	HostName github.com
      	User git
      	IdentityFile ~/.ssh/gh
      	AddKeysToAgent yes
    '';
  };
}
