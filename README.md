# .nixos – Laptop „amboss“

Komplettes NixOS-Setup inkl. Dotfiles. Ziel: Laptop löschen → aus diesem Repo
wiederherstellen.

## Spickzettel (Alltag)

Im Repo-Ordner (`~/.nixos`) ausführen. `just` ohne Argumente zeigt alle Befehle.

| Was                               | Befehl          |
| --------------------------------- | --------------- |
| Änderung im Repo anwenden         | `just switch`   |
| Alles aktualisieren               | `just update`   |
| Update war schlecht → zurück      | `just rollback` |
| Speicher freigeben                | `just clean`    |
| Nur prüfen, nichts ändern         | `just check`    |

**System startet nach einem Update nicht mehr?** Beim Booten im Menü einfach
einen älteren Eintrag auswählen – die letzten 10 Stände bleiben erhalten.

**Fernseher/Monitor:** HDMI einstecken. Anordnung/Spiegeln unter
*Einstellungen → Bildschirme*, Ton über HDMI im Schnellmenü oben rechts.

**Programm installieren:** Paketnamen auf <https://search.nixos.org/packages>
suchen, in `modules/home/*.nix` unter `home.packages` eintragen, `just switch`.

## Aufbau

```
flake.nix                 Einstiegspunkt, Versionen der Quellen
justfile                  Kurzbefehle
hosts/amboss/             dieses Gerät: Hardware, Partitionierung
modules/nixos/            System: Boot, Desktop, Nvidia, Netzwerk, Docker, Theme
modules/home/             Benutzer: GNOME, Firefox, Shell, Terminal, Editoren, Dev-Tools
dotfiles/                 rohe Config-Dateien ohne eigenes Modul
wallpapers/               Hintergrundbilder
```

Ricing: zentrale Stelle ist `modules/nixos/theme.nix` (Stylix – ein Farbschema
für alles), GNOME-Erweiterungen in `modules/home/gnome.nix`.

## Neuinstallation

**Achtung: löscht die gesamte Festplatte.** Vorher persönliche Daten sichern –
im Repo liegt nur die Konfiguration.

1. NixOS-ISO von <https://nixos.org/download> booten, WLAN verbinden.
2. Repo holen:
   ```sh
   nix-shell -p git
   git clone https://github.com/DieWand/.nixos.git && cd .nixos
   ```
3. Festplatte prüfen (`lsblk`) und ggf. `device` in `hosts/amboss/disko.nix` anpassen.
4. Partitionieren, verschlüsseln, einhängen (fragt nach dem neuen LUKS-Passwort):
   ```sh
   sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
     --mode destroy,format,mount hosts/amboss/disko.nix
   ```
5. Nur beim allerersten Mal / bei neuer Hardware – Hardware-Datei erzeugen:
   ```sh
   sudo nixos-generate-config --no-filesystems --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix hosts/amboss/
   git add -A
   ```
6. Installieren und neu starten:
   ```sh
   sudo nixos-install --flake .#amboss
   reboot
   ```
7. Als `nschulze` mit Passwort `changeme` anmelden, **sofort `passwd` ausführen**.
   Repo nach `~/.nixos` klonen, geänderte Dateien (inkl. `flake.lock`) committen und pushen.
8. Einmalig: `rustup default stable`, in JetBrains/Firefox anmelden.

## Offene Punkte

Im Code mit `TODO(hardware)` markiert: genaues Modell, Festplattenname,
Nvidia-Bus-IDs, ASUS-Dienste.
