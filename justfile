# `just` ohne Argumente zeigt diese Liste.
default:
    @just --list

# Änderungen aus dem Repo anwenden
switch:
    sudo nixos-rebuild switch --flake .#amboss

# Neuesten Stand aus Git holen und anwenden
sync:
    git pull --ff-only
    sudo nixos-rebuild switch --flake .#amboss

# Änderungen testen, ohne sie ins Bootmenü zu übernehmen (Neustart = alter Stand)
test:
    sudo nixos-rebuild test --flake .#amboss

# Alles aktualisieren (Pakete, Treiber, Kernel) und anwenden
update:
    nix flake update
    sudo nixos-rebuild switch --flake .#amboss

# Zum vorherigen Stand zurück
rollback:
    sudo nixos-rebuild switch --rollback

# Alte Stände löschen und Speicher freigeben
clean:
    sudo nix-collect-garbage --delete-older-than 14d
    sudo nixos-rebuild boot --flake .#amboss

# Konfiguration prüfen, ohne etwas zu ändern
check:
    nix flake check

# Nix-Dateien formatieren
fmt:
    nix fmt

# Secrets einmalig einrichten (Schlüssel erzeugen, verschlüsselte Datei anlegen)
secrets-init:
    #!/usr/bin/env bash
    set -euo pipefail
    key=/var/lib/sops-nix/key.txt
    if ! sudo test -f "$key"; then
      sudo mkdir -p "$(dirname "$key")"
      sudo age-keygen -o "$key"
      sudo chmod 600 "$key"
    fi
    pub="$(sudo age-keygen -y "$key")"
    printf 'creation_rules:\n  - path_regex: secrets/.*\\.yaml$\n    age: %s\n' "$pub" > .sops.yaml
    if [ ! -f secrets/secrets.yaml ]; then
      mkdir -p secrets
      printf 'restic:\n  password: %s\n' "$(head -c 32 /dev/urandom | base64)" > secrets/secrets.yaml
      sops --encrypt --in-place secrets/secrets.yaml
    fi
    git add .sops.yaml secrets
    echo
    echo "Fertig. Diesen privaten Schlüssel JETZT im Passwortmanager speichern:"
    echo
    sudo grep AGE-SECRET-KEY "$key"
    echo
    echo "Danach: just switch, dann committen und pushen."

# Secrets bearbeiten (öffnet die entschlüsselte Datei im Editor)
secrets:
    SOPS_AGE_KEY="$(sudo grep AGE-SECRET-KEY /var/lib/sops-nix/key.txt)" sops secrets/secrets.yaml

# Backup sofort starten
backup:
    sudo systemctl start restic-backups-home.service
