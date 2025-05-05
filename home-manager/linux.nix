{
  pkgs,
  unstable,
  ...
}: {
  home.username = "thomasgl";
  home.homeDirectory = "/home/thomasgl";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    neovim
    chezmoi
    tldr
    obsidian
    # unstable.vscode
  ];

  programs.fish.enable = true;
  programs.fish.functions = {
    modify_nix = ''
      cd ~/nix/
      nvim
    '';
    rebuild_nix = ''
      nix run home-manager/release-24.11 -- switch --flake ~/nix#thomasgl
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
      	IdentityFile ~/.ssh/github
      	AddKeysToAgent yes
    '';
  };

  home.sessionVariables = {};
}
