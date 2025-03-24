{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.fish.enable = true;
  environment.shells = [pkgs.fish];

  environment.systemPackages = with pkgs; [colima];

  # Set fish as default shell using activation script
  system.activationScripts.postActivation.text = ''
    echo "setting default shell to fish"
    sudo chsh -s ${pkgs.fish}/bin/fish thomasglopes
  '';

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "vim";

  system.stateVersion = 5;
}
