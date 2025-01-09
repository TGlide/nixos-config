{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    (
      if pkgs.stdenv.isDarwin
      then ./darwin.nix
      else ./nixos.nix
    )
  ];

  # Shared configuration goes here
  home.packages = with pkgs; [
    # Common packages for both systems
  ];
}
