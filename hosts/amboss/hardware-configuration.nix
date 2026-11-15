# PLATZHALTER – wird bei der Installation ersetzt durch die Ausgabe von
#   nixos-generate-config --no-filesystems --root /mnt
# (Dateisysteme kommen aus disko.nix, deshalb --no-filesystems.)
{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
