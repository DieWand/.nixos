# Secrets (Passwörter, Schlüssel) liegen verschlüsselt im Repo: secrets/secrets.yaml
#
#   just secrets-init   einmalig: Schlüssel erzeugen, Datei anlegen
#   just secrets        Secrets bearbeiten
#
# Entschlüsselt wird mit EINEM age-Schlüssel unter /var/lib/sops-nix/key.txt.
# Dieser Schlüssel gehört in den Passwortmanager – ohne ihn sind die Secrets
# nach einem Wipe verloren. install.sh fragt bei der Neuinstallation danach.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  file = ../../secrets/secrets.yaml;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [
    pkgs.sops
    pkgs.age
  ];

  # Greift erst, sobald `just secrets-init` die Datei angelegt hat.
  sops = lib.mkIf (builtins.pathExists file) {
    defaultSopsFile = file;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      "restic/password" = { };

      # Beispiel für weitere Secrets (Eintrag zusätzlich in secrets.yaml nötig):
      # "ssh/id_ed25519" = {
      #   owner = "nschulze";
      #   path = "/home/nschulze/.ssh/id_ed25519";
      #   mode = "0600";
      # };
    };
  };
}
