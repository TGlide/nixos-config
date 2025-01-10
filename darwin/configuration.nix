{
  config,
  pkgs,
  inputs,
  ...
}: {
	programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  # Set fish as default shell using activation script
  system.activationScripts.postActivation.text = ''
    echo "setting default shell to fish"
    sudo chsh -s ${pkgs.fish}/bin/fish thomasglopes
  '';


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.variables.EDITOR = "vim";

  system.stateVersion = 5;
}
