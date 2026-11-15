# 05 – Daten & Secrets

Drei Schutzebenen mit unterschiedlichem Zweck:

| Ebene | Schützt vor | Schützt nicht vor | Status |
| --- | --- | --- | --- |
| Systemstände (Generationen) | Kaputtem Update | Datenverlust | aktiv |
| Snapshots von `/home` | Versehentlichem Löschen/Überschreiben | Plattendefekt, Diebstahl, Wipe | aktiv |
| Backup (restic) | Plattendefekt, Diebstahl, Wipe | – | **wartet auf Ziel** |

## Snapshots

snapper legt stündlich einen Snapshot von `/home` an. Aufbewahrt werden 10
stündliche, 7 tägliche und 4 wöchentliche.

Zurückholen: App **Btrfs Assistant** → Reiter *Snapper* → *Browse/Restore* →
Snapshot wählen → Datei herauskopieren.

Im Terminal liegen die Stände unter `/home/.snapshots/<nr>/snapshot/nschulze/…`;
Liste mit `snapper -c home list`.

## Secrets

Passwörter und Schlüssel liegen mit sops verschlüsselt in
`secrets/secrets.yaml` und dürfen so ins Repo. Entschlüsselt wird mit **einem
age-Schlüssel** unter `/var/lib/sops-nix/key.txt`.

> Der age-Schlüssel ist das Einzige, was außerhalb des Repos aufbewahrt werden
> muss (Passwortmanager). Ohne ihn sind Secrets und Backup nach einem Wipe
> nicht mehr lesbar.

**Einrichten (einmalig):** `just secrets-init`. Erzeugt den Schlüssel, legt
`.sops.yaml` und `secrets/secrets.yaml` an (mit einem zufälligen
Backup-Passwort) und zeigt den privaten Schlüssel zum Abspeichern. Danach
`just switch`, committen, pushen.

**Secret hinzufügen:**

1. `just secrets` – Wert eintragen, speichern, schließen:
   ```yaml
   wifi:
     zuhause: geheimes-passwort
   ```
2. In `modules/nixos/secrets.nix` anmelden:
   ```nix
   secrets."wifi/zuhause" = { };
   ```
3. `just switch`. Der Klartext liegt dann unter `/run/secrets/wifi/zuhause`
   (nur für root lesbar; mit `owner = "nschulze";` für dich).

Jeder in `secrets.nix` angemeldete Eintrag muss in der Datei existieren, sonst
bricht der Build ab.

**Nach einem Wipe:** `install.sh` fragt nach dem age-Schlüssel und legt ihn ab.
Nachträglich: Schlüssel als `/var/lib/sops-nix/key.txt` speichern (root,
Rechte 600), dann `just switch`.

## Backup

restic sichert `/home/nschulze` verschlüsselt und inkrementell. Ausgenommen
sind Caches, Papierkorb, die Steam-Bibliothek, Docker-Daten und Build-Ordner
(`node_modules`, `target`).

**Aktivieren:**

1. `just secrets-init` (falls noch nicht geschehen).
2. In `hosts/amboss/default.nix` das Ziel eintragen:
   ```nix
   amboss.backup.repository = "sftp:user@server:/backups/amboss";
   ```
3. `just switch`.

| Ziel | Schreibweise | Zusätzlich nötig |
| --- | --- | --- |
| USB-Platte | `/run/media/nschulze/<Name>/restic` | Platte muss angesteckt sein; Start per `just backup` |
| Server / NAS | `sftp:user@host:/pfad` | SSH-Schlüssel für root, der sich dort anmelden darf |
| Cloud (B2, S3 …) | `b2:bucket:/amboss`, `s3:…` | Zugangsdaten als weiteres Secret (`environmentFile`) |

Die letzten beiden Varianten brauchen noch eine kleine Ergänzung in
`backup.nix`, sobald das Ziel feststeht.

**Betrieb:** täglich automatisch, verpasste Läufe werden nach dem Einschalten
nachgeholt. Aufbewahrt: 7 tägliche, 4 wöchentliche, 6 monatliche Stände.

```sh
just backup                                   # sofort starten
systemctl status restic-backups-home          # letzter Lauf
journalctl -u restic-backups-home -e          # Protokoll
```

**Wiederherstellen** (`<ziel>` wie oben eingetragen):

```sh
sudo restic -r <ziel> -p /run/secrets/restic/password snapshots
sudo restic -r <ziel> -p /run/secrets/restic/password restore latest --target /
# einzelner Ordner:
sudo restic -r <ziel> -p /run/secrets/restic/password restore latest \
  --target /tmp/zurueck --include /home/nschulze/Dokumente
```

## Was in den Passwortmanager gehört

- LUKS-Passwort der Festplatte
- age-Schlüssel (`AGE-SECRET-KEY-…`)
- Zugang zum GitHub-Repo
- Zugangsdaten des Backup-Ziels
