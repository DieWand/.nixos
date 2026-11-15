# Host "amboss": der persönliche Laptop (vermutlich ASUS TUF Gaming A17).
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

    # TODO(hardware): sobald das genaue Modell feststeht, das passende
    # nixos-hardware-Modul ergänzen, z. B.:
    # inputs.nixos-hardware.nixosModules.asus-fa706ic
  ];

  networking.hostName = "amboss";

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
