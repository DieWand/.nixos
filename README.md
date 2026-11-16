# .nixos – Laptop „amboss“

Komplettes NixOS-Setup inkl. Dotfiles. Ziel: Laptop löschen → aus diesem Repo
wiederherstellen.

Ausführliche Dokumentation: [docs/](docs/README.md) – Konzept, Installation,
Alltag, Anpassen, Daten & Secrets, Fehlerbehebung, Hardware.

## Spickzettel (Alltag)

Im Repo-Ordner (`~/.nixos`) ausführen. `just` ohne Argumente zeigt alle Befehle.

| Was                               | Befehl          |
| --------------------------------- | --------------- |
| Änderung im Repo anwenden         | `just switch`   |
| Stand aus Git holen und anwenden  | `just sync`     |
| Alles aktualisieren               | `just update`   |
| Update war schlecht → zurück      | `just rollback` |
| Speicher freigeben                | `just clean`    |
| Nur prüfen, nichts ändern         | `just check`    |

**Ohne Terminal** (Symbole im Dock und in der App-Übersicht):

- *System aktualisieren* – holt den neuesten Stand aus Git und wendet ihn an.
  Rechtsklick → zusätzlich alle Pakete aktualisieren.
- *Grafikmodus* – sparsam / Standard / Nvidia-Leistung (MUX). Dasselbe gibt es
  im Schnellmenü oben rechts.

**Erinnerung:** Ist der Software-Stand älter als 14 Tage, erscheint nach dem
Anmelden eine Benachrichtigung mit dem Knopf „Jetzt aktualisieren“
(Schwelle: `reminderDays` in `modules/home/shortcuts.nix`).

**System startet nach einem Update nicht mehr?** Beim Booten im Menü einfach
einen älteren Eintrag auswählen – die letzten 10 Stände bleiben erhalten.

**Fernseher/Monitor:** HDMI einstecken. Anordnung/Spiegeln unter
*Einstellungen → Bildschirme*, Ton über HDMI im Schnellmenü oben rechts.

**Programm installieren:** Paketnamen auf <https://search.nixos.org/packages>
suchen, in `modules/home/*.nix` unter `home.packages` eintragen, `just switch`.

## Daten, Secrets, Programme

**Datei versehentlich gelöscht/überschrieben?** App *Btrfs Assistant* → Snapper →
Snapshot wählen → Datei zurückholen. Snapshots von `/home` entstehen stündlich
(aufbewahrt: 10 stündliche, 7 tägliche, 4 wöchentliche). Sie liegen auf derselben
Platte und ersetzen kein Backup.

**Backup** (restic, verschlüsselt) – läuft erst, wenn beides erledigt ist:

1. `just secrets-init` (einmalig, siehe unten)
2. Ziel in `hosts/amboss/default.nix` eintragen (`amboss.backup.repository`),
   dann `just switch`

Danach täglich automatisch; verpasste Läufe werden nach dem Einschalten
nachgeholt. Sofort starten: `just backup`. Wiederherstellen:
`sudo restic -r <ziel> -p /run/secrets/restic/password restore latest --target /`.

**Secrets** liegen verschlüsselt in `secrets/secrets.yaml`:

- `just secrets-init` – einmalig. Zeigt am Ende den privaten Schlüssel:
  **im Passwortmanager speichern**, ohne ihn sind Secrets und Backup nach einem
  Wipe nicht mehr lesbar. Die Neuinstallation fragt danach.
- `just secrets` – bearbeiten. Neue Einträge zusätzlich in
  `modules/nixos/secrets.nix` anmelden.

**Programme per Klick:** App *Software* (Flatpak/Flathub). So installierte
Programme stehen nicht im Repo und müssen nach einem Wipe neu geklickt werden.

## Aufbau

```
flake.nix                 Einstiegspunkt, Versionen der Quellen
justfile                  Kurzbefehle
install.sh                Neuinstallation in einem Schritt
docs/                     ausführliche Dokumentation
scripts/hardware-info.sh  sammelt Hardware-Daten
hosts/amboss/             dieses Gerät: Hardware, Partitionierung
modules/nixos/            System: Boot, Desktop, Nvidia, Netzwerk, Docker, Steam, Theme,
                          Snapshots, Secrets, Backup
modules/home/             Benutzer: GNOME, Firefox, Shell, Terminal, Editoren, Dev-Tools, Verknüpfungen
secrets/                  verschlüsselte Secrets (entsteht durch `just secrets-init`)
dotfiles/                 rohe Config-Dateien ohne eigenes Modul
wallpapers/               Hintergrundbilder
```

Ricing: zentrale Stelle ist `modules/nixos/theme.nix` (Stylix – ein Farbschema
für alles), GNOME-Erweiterungen in `modules/home/gnome.nix`.

## Neuinstallation

**Achtung: löscht die gesamte Festplatte.** Vorher persönliche Daten sichern –
im Repo liegt nur die Konfiguration.

NixOS-ISO von <https://nixos.org/download> booten, WLAN verbinden, Terminal öffnen:

```sh
nix-shell -p git --run "git clone https://github.com/DieWand/.nixos && sudo ./.nixos/install.sh"
```

Das Skript zeigt die Zielfestplatte, verlangt eine Bestätigung (`ja`), fragt nach
dem neuen Verschlüsselungs-Passwort und installiert dann alles. Andere Festplatte:
`sudo ./.nixos/install.sh /dev/sda`.

Danach: `reboot`, als `nschulze` mit Passwort `changeme` anmelden und **sofort
`passwd` ausführen**. Das Repo liegt bereits unter `~/.nixos`; dort geänderte
Dateien (`hardware-configuration.nix`, `flake.lock`) committen und pushen.
Einmalig: `rustup default stable`, in Steam/JetBrains/Firefox anmelden.

## Offene Punkte

Name/E-Mail für Git (`modules/home/git.nix`), Backup-Ziel, Wallpaper.
