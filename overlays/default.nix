{
  # config,
  pkgs,
  # lib,
  ...
}: [
  (import ./discord.nix {inherit pkgs;})
  (import ./vesktop.nix)
]
