#!/usr/bin/env bash
# Komplette Neuinstallation vom NixOS-Installationsstick aus.
# ACHTUNG: löscht die gesamte Zielfestplatte.
#
#   sudo ./install.sh                  # Festplatte aus hosts/amboss/disko.nix
#   sudo ./install.sh /dev/sda         # andere Festplatte verwenden
#   sudo ./install.sh --weiter         # abgebrochene Installation fortsetzen,
#                                      # OHNE die Platte erneut zu löschen
#   sudo ./install.sh --ohne-jetbrains # die großen JetBrains-Downloads auslassen
#                                      # (später nachholen, siehe Hinweis am Ende)
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

RESUME=0
SKIP_IDES=0
DISK_ARG=""
for arg in "$@"; do
  case "$arg" in
    --weiter) RESUME=1 ;;
    --ohne-jetbrains) SKIP_IDES=1 ;;
    /dev/*) DISK_ARG="$arg" ;;
    *) echo "Unbekanntes Argument: $arg" >&2; exit 1 ;;
  esac
done

disko() {
  "${NIX[@]}" run github:nix-community/disko/latest -- "$@"
}

if [ -n "$DISK_ARG" ]; then
  sed -i "s#^\(\s*device = \)\"[^\"]*\";#\1\"$DISK_ARG\";#" "$DISKO_FILE"
fi
DISK="$(sed -n 's/^\s*device = "\([^"]*\)";.*/\1/p' "$DISKO_FILE" | head -n1)"

if [ ! -b "$DISK" ]; then
  echo "Festplatte $DISK nicht gefunden. Vorhandene Laufwerke:" >&2
  lsblk -d -o NAME,SIZE,MODEL >&2
  echo "Aufruf mit Laufwerk: sudo $0 /dev/<name>" >&2
  exit 1
fi

if [ "$RESUME" -eq 1 ]; then
  echo "==> Installation fortsetzen – die Platte wird NICHT gelöscht"
  if ! mountpoint -q /mnt; then
    echo "==> Platte entsperren und einhängen (fragt nach dem LUKS-Passwort)"
    disko --mode mount "$DISKO_FILE"
  fi
else
  echo
  lsblk -o NAME,SIZE,MODEL,MOUNTPOINTS "$DISK"
  echo
  echo "!!! ALLE DATEN AUF $DISK WERDEN GELÖSCHT !!!"
  read -r -p "Zum Fortfahren 'ja' eingeben: " answer
  [ "$answer" = "ja" ] || { echo "Abgebrochen."; exit 1; }

  echo "==> Partitionieren und verschlüsseln (fragt nach dem neuen LUKS-Passwort)"
  disko --mode destroy,format,mount --yes-wipe-all-disks "$DISKO_FILE"
fi

if [ ! -s "$HW_FILE" ] || grep -q PLATZHALTER "$HW_FILE"; then
  echo "==> Hardware-Konfiguration erzeugen"
  nixos-generate-config --no-filesystems --root /mnt --show-hardware-config > "$HW_FILE"
fi

if [ "$SKIP_IDES" -eq 1 ]; then
  sed -i 's/amboss\.jetbrains\.enable = true;/amboss.jetbrains.enable = false;/' "$REPO/hosts/$HOST/default.nix"
fi

if [ -f "$REPO/secrets/secrets.yaml" ] && [ ! -s /mnt/var/lib/sops-nix/key.txt ]; then
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
# Große Downloads (v. a. die JetBrains-IDEs, je ~1 GB) brechen bei wackeliger
# Verbindung gelegentlich ab. Bereits Geladenes bleibt erhalten, deshalb
# einfach mehrfach versuchen.
attempt=1
until nixos-install --no-root-passwd --flake "$REPO#$HOST"; do
  if [ "$attempt" -ge 5 ]; then
    cat >&2 <<MSG

✘ Installation nach $attempt Versuchen nicht abgeschlossen.
  Die Platte ist fertig eingerichtet, bereits Geladenes bleibt erhalten.

  Erneut versuchen (ohne zu löschen):   sudo $0 --weiter
  Falls es an den JetBrains-Downloads hängt (Meldung „cannot download
  …tar.gz“):                            sudo $0 --weiter --ohne-jetbrains
  Tipp: LAN-Kabel statt WLAN verwenden.
MSG
    exit 1
  fi
  attempt=$((attempt + 1))
  echo
  echo "==> Fehlgeschlagen – Versuch $attempt von 5 in 10 Sekunden"
  sleep 10
done

echo "==> Stand dieser Installation festhalten (Commit)"
git -C "$REPO" -c safe.directory='*' add -A
git -C "$REPO" -c safe.directory='*' -c user.name=nschulze -c user.email=nschulze@amboss \
  commit -q -m "amboss: Stand nach Installation" || true

echo "==> Repo ins neue System kopieren"
TARGET="/mnt/home/$USER_NAME/.nixos"
mkdir -p "$(dirname "$TARGET")"
rm -rf "$TARGET"
cp -a "$REPO" "$TARGET"
nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME"

cat <<MSG

✔ Fertig. Jetzt 'reboot' eingeben und den Stick abziehen.

  Anmelden als:  $USER_NAME   Passwort: changeme   → danach sofort 'passwd'
  Einmalig 'gh auth login' (GitHub-Anmeldung), danach im Dock
  „System aktualisieren“ – das lädt auch den Stand dieser Installation hoch.
MSG

if [ "$SKIP_IDES" -eq 1 ]; then
  cat <<MSG

  JetBrains-IDEs wurden ausgelassen. Nachholen: in
  ~/.nixos/hosts/$HOST/default.nix  amboss.jetbrains.enable = true;  setzen,
  dann 'just switch'.
MSG
fi
