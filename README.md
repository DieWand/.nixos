# .nixos – Laptop „amboss“

Komplettes NixOS-Setup inkl. Dotfiles. Ziel: Laptop löschen → aus diesem Repo
wiederherstellen.

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

## Aufbau

```
flake.nix                 Einstiegspunkt, Versionen der Quellen
justfile                  Kurzbefehle
install.sh                Neuinstallation in einem Schritt
hosts/amboss/             dieses Gerät: Hardware, Partitionierung
modules/nixos/            System: Boot, Desktop, Nvidia, Netzwerk, Docker, Steam, Theme
modules/home/             Benutzer: GNOME, Firefox, Shell, Terminal, Editoren, Dev-Tools, Verknüpfungen
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

Im Code mit `TODO(hardware)` markiert: genaues Modell, Festplattenname,
Nvidia-Bus-IDs, ASUS-Dienste.
