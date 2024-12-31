{
  # config,
  pkgs,
  # lib,
  ...
}: {
  nixpkgs.overlays = [
    (import ./discord.nix {inherit pkgs;})
    (import ./vesktop.nix)
  ];
}
