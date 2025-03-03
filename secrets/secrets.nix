let
  systemKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgp9TxUUzml3wbuTLeWRe2vh09JCvxWSdWdweVgI1NH nix_system";
in {
  "kolide.age".publicKeys = [systemKey];
}
