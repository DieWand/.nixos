# 01 – Konzept

## Ziel

Der Laptop „amboss“ ist vollständig in diesem Repo beschrieben. Nach einem
Wipe stellt ein Befehl System, Programme und Einstellungen wieder her. Der
Laptop wird unregelmäßig benutzt – deshalb gilt:

- **Bedienung per Maus.** Kein Fenstermanager mit Tastenkürzeln, sondern GNOME
  mit Dock, Fensterknöpfen und Schnellmenü.
- **Nichts ändert sich von allein.** Updates laufen nur, wenn du sie startest.
- **Immer ein Weg zurück.** Die letzten 10 Systemstände bleiben im Bootmenü.

## Grundbegriffe

| Begriff | Bedeutung |
| --- | --- |
| **Flake** (`flake.nix`) | Einstiegspunkt. Legt fest, aus welchen Quellen gebaut wird. |
| **`flake.lock`** | Die exakt verwendeten Versionen dieser Quellen. Ein Software-Update ändert genau diese Datei. |
| **Generation** | Ein gebauter Systemstand. Jedes `switch` erzeugt eine neue; alte bleiben startbar. |
| **Home Manager** | Verwaltet alles unter `~` (Dotfiles, Benutzerprogramme) – hier als Teil des Systems, also ein gemeinsamer Befehl. |
| **Host** | Ein konkretes Gerät (`hosts/amboss`). |
| **Modul** | Eine `.nix`-Datei für ein Thema (`modules/…`). |

## Bausteine

| Bereich | Lösung | Datei |
| --- | --- | --- |
| Basis | NixOS 26.05 (stable), systemd-boot | `modules/nixos/core.nix` |
| Festplatte | LUKS-Verschlüsselung, btrfs, zram-Swap (disko) | `hosts/amboss/disko.nix` |
| Desktop | GNOME auf Wayland, PipeWire, Flatpak | `modules/nixos/desktop.nix` |
| Aussehen | Stylix: Farben aus dem Wallpaper, Papirus-Icons, Plymouth, GNOME-Erweiterungen | `modules/nixos/theme.nix`, `modules/home/gnome.nix` |
| Grafik | Nvidia-Treiber, Umschaltung über supergfxctl | `modules/nixos/nvidia.nix`, `laptop.nix` |
| Laptop | Energieprofile, Bluetooth, Firmware, ASUS-Dienste | `modules/nixos/laptop.nix` |
| Spiele | Steam, Proton-GE, GameMode, MangoHud | `modules/nixos/gaming.nix` |
| Entwicklung | Docker; Zed, JetBrains, Toolchains, direnv | `modules/nixos/dev.nix`, `modules/home/{editor,dev}.nix` |
| Shell | fish, starship, Ghostty | `modules/home/{shell,terminal}.nix` |
| Browser | Firefox mit DRM (Netflix) | `modules/home/browser.nix` |
| Verknüpfungen | Update, Grafikmodus, Update-Erinnerung | `modules/home/shortcuts.nix` |
| Snapshots | snapper auf `/home` | `modules/nixos/snapshots.nix` |
| Backup | restic (noch ohne Ziel) | `modules/nixos/backup.nix` |
| Secrets | sops-nix mit age-Schlüssel | `modules/nixos/secrets.nix` |

## Was im Repo liegt – und was nicht

| Im Repo (nach Wipe automatisch wieder da) | Nicht im Repo |
| --- | --- |
| Betriebssystem, Treiber, alle Programme | Persönliche Dateien (Dokumente, Projekte, Downloads) → Backup |
| Einstellungen von GNOME, Shell, Terminal, Git, Editor | Logins in Firefox, Steam, JetBrains |
| Partitionierung und Verschlüsselungs-Layout | Per „Software“-App installierte Flatpaks |
| Secrets (verschlüsselt, sobald eingerichtet) | Der age-Schlüssel und das LUKS-Passwort → Passwortmanager |
| | Steam-Spiele (lädt Steam neu), WLAN-Passwörter |

## Bewusste Entscheidungen

- **GNOME statt Tiling-WM:** ohne Einarbeitung bedienbar, HDMI-Hotplug
  funktioniert von selbst.
- **Stable statt unstable:** seltene Nutzung verträgt keine Überraschungen.
- **Keine automatischen Updates:** stattdessen eine Erinnerung nach 14 Tagen.
- **Toolchains global installiert:** IDEs finden Compiler ohne Zusatzschritte;
  Projekte können per eigener `flake.nix` + direnv abweichende Versionen nutzen.
- **Kein Secure Boot:** Aufwand und Fehlerrisiko stehen für einen Privatlaptop
  nicht im Verhältnis.

## Stand der Prüfung

Die Konfiguration wurde vollständig ausgewertet (alle Optionen gültig, alle
Pakete vorhanden), die eigenen Skripte wurden gebaut. Die Hardware-Daten des Geräts
sind eingetragen ([07 – Hardware](07-hardware.md)). Sie wurde **noch nicht auf
der echten Hardware installiert**.
