# Automatische Snapshots von /home (btrfs + snapper).
# Zurückholen per Maus: App „Btrfs Assistant“ → Snapper → Browse/Restore.
# Schützt vor versehentlichem Löschen/Überschreiben – NICHT vor Plattendefekt
# oder Diebstahl (dafür: backup.nix).
{ pkgs, ... }:
{
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    ALLOW_USERS = [ "nschulze" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 10;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };

  environment.systemPackages = [ pkgs.btrfs-assistant ];
}
