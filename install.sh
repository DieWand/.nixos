#!/usr/bin/env bash
# Komplette Neuinstallation vom NixOS-Installationsstick aus.
# ACHTUNG: löscht die gesamte Zielfestplatte.
#
#   sudo ./install.sh              # Festplatte aus hosts/amboss/disko.nix
#   sudo ./install.sh /dev/sda     # andere Festplatte verwenden
set -euo pipefail

HOST=amboss
USER_NAME=nschulze
REPO="$(cd "$(dirname "$0")" && pwd)"
DISKO_FILE="$REPO/hosts/$HOST/disko.nix"
HW_FILE="$REPO/hosts/$HOST/hardware-configuration.nix"
NIX=(nix --extra-experimental-features "nix-command flakes")

if [ "$(id -u)" -ne 0 ]; then
  echo "Bitte mit sudo starten: sudo $0" >&2
  exit 1
fi

if [ -n "${1:-}" ]; then
  sed -i "s#^\(\s*device = \)\"[^\"]*\";#\1\"$1\";#" "$DISKO_FILE"
fi
DISK="$(sed -n 's/^\s*device = "\([^"]*\)";.*/\1/p' "$DISKO_FILE" | head -n1)"

if [ ! -b "$DISK" ]; then
  echo "Festplatte $DISK nicht gefunden. Vorhandene Laufwerke:" >&2
  lsblk -d -o NAME,SIZE,MODEL >&2
  echo "Aufruf mit Laufwerk: sudo $0 /dev/<name>" >&2
  exit 1
fi

echo
lsblk -o NAME,SIZE,MODEL,MOUNTPOINTS "$DISK"
echo
echo "!!! ALLE DATEN AUF $DISK WERDEN GELÖSCHT !!!"
read -r -p "Zum Fortfahren 'ja' eingeben: " answer
[ "$answer" = "ja" ] || { echo "Abgebrochen."; exit 1; }

echo "==> Partitionieren und verschlüsseln (fragt nach dem neuen LUKS-Passwort)"
"${NIX[@]}" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks "$DISKO_FILE"

if grep -q PLATZHALTER "$HW_FILE"; then
  echo "==> Hardware-Konfiguration erzeugen"
  nixos-generate-config --no-filesystems --root /mnt --show-hardware-config > "$HW_FILE"
fi

if [ -f "$REPO/secrets/secrets.yaml" ]; then
  echo "==> Secrets-Schlüssel"
  echo "Privaten age-Schlüssel aus dem Passwortmanager einfügen (AGE-SECRET-KEY-…),"
  read -r -s -p "leer lassen zum Überspringen: " agekey
  echo
  if [ -n "$agekey" ]; then
    install -d -m 700 /mnt/var/lib/sops-nix
    (umask 077; printf '%s\n' "$agekey" > /mnt/var/lib/sops-nix/key.txt)
  else
    echo "Übersprungen – Secrets (und Backup) funktionieren erst, wenn der Schlüssel"
    echo "unter /var/lib/sops-nix/key.txt liegt."
  fi
fi

# Flakes sehen nur Dateien, die Git kennt.
git -C "$REPO" add -A

echo "==> NixOS installieren (dauert eine Weile)"
nixos-install --no-root-passwd --flake "$REPO#$HOST"

echo "==> Repo ins neue System kopieren"
TARGET="/mnt/home/$USER_NAME/.nixos"
mkdir -p "$(dirname "$TARGET")"
rm -rf "$TARGET"
cp -a "$REPO" "$TARGET"
nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME"

cat <<MSG

✔ Fertig. Jetzt 'reboot' eingeben und den Stick abziehen.

  Anmelden als:  $USER_NAME   Passwort: changeme   → danach sofort 'passwd'
  Anschließend in ~/.nixos die geänderten Dateien committen und pushen
  (hardware-configuration.nix, flake.lock).
MSG
