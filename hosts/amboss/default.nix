# Host "amboss": ASUS TUF Gaming A17 FA707RR
# (Ryzen 7 6800H, Radeon 680M + RTX 3070 mit MUX, 16 GB RAM, 1 TB NVMe).
{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix

    ./hardware-configuration.nix
    ./disko.nix

    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/dev.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/theme.nix
    ../../modules/nixos/snapshots.nix
    ../../modules/nixos/secrets.nix
    ../../modules/nixos/backup.nix

    # Für das FA707RR gibt es kein eigenes nixos-hardware-Profil; diese
    # allgemeinen Bausteine entsprechen dem des Schwestermodells FA507RM.
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "amboss";

  # JetBrains-IDEs (je ~1 GB Download direkt von JetBrains). Auf false setzen,
  # falls die Downloads bei der Installation scheitern; später nachholen.
  amboss.jetbrains.enable = true;

  # Backup-Ziel – noch offen. Eintragen, dann `just switch` (siehe backup.nix).
  # amboss.backup.repository = "sftp:user@server:/backups/amboss";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.nschulze = import ../../modules/home;
  };

  # Nicht ändern: legt fest, mit welcher Version das System installiert wurde.
  system.stateVersion = "26.05";
}
