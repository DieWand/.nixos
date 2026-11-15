# Backup des Home-Ordners mit restic (verschlüsselt, inkrementell).
# Aktiv, sobald (1) `just secrets-init` gelaufen ist und (2) in
# hosts/amboss/default.nix ein Ziel eingetragen ist:
#   amboss.backup.repository = "sftp:user@server:/backups/amboss";
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.amboss.backup;
  enabled = cfg.repository != null && config.sops.secrets ? "restic/password";
in
{
  options.amboss.backup.repository = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "sftp:user@server:/backups/amboss";
    description = ''
      restic-Ziel. Beispiele: "/run/media/nschulze/Backup/restic" (USB-Platte),
      "sftp:user@host:/pfad" (Server/NAS), "b2:bucket:/amboss" (Cloud).
    '';
  };

  config = lib.mkMerge [
    { environment.systemPackages = [ pkgs.restic ]; }

    (lib.mkIf enabled {
      services.restic.backups.home = {
        repository = cfg.repository;
        passwordFile = config.sops.secrets."restic/password".path;
        initialize = true;

        paths = [ "/home/nschulze" ];
        exclude = [
          "/home/nschulze/.cache"
          "/home/nschulze/.local/share/Trash"
          "/home/nschulze/.local/share/Steam"
          "/home/nschulze/.local/share/docker"
          "/home/nschulze/.var/app/*/cache"
          "/home/nschulze/.cargo/registry"
          "/home/nschulze/.rustup"
          "/home/nschulze/.npm"
          "/home/nschulze/.gradle/caches"
          "/home/nschulze/.m2/repository"
          "node_modules"
          "target"
          ".direnv"
        ];

        # Täglich; verpasste Läufe werden nach dem Einschalten nachgeholt.
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "10min";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];
      };
    })
  ];
}
