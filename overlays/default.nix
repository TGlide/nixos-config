{
  # config,
  # pkgs,
  # lib,
  ...
}: {
  nixpkgs.overlays = [
    # (import ./vesktop.nix)
  ];
}
