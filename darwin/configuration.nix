{
  config,
  pkgs,
  inputs,
  ...
}: {

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.variables.EDITOR = "vim";

  system.stateVersion = 5;
}
