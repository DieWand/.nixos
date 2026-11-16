# 03 – Alltag

## Zwei Oberflächen

Am Anmeldebildschirm: Namen anklicken, dann unten rechts das **Zahnrad** –
dort wählst du die Sitzung. Die Wahl bleibt bis zum nächsten Umstellen.

| Sitzung | Was |
| --- | --- |
| **niri** | Die gestaltete Oberfläche im Stil der Wallpaper (siehe unten) |
| **GNOME** | Klassisch und robust – die Rückfallebene, wenn in niri etwas hakt |

Programme, Dateien und Einstellungen sind in beiden dieselben.

## niri

Fenster liegen nebeneinander auf einem Band, das seitlich weiterläuft; neue
Fenster öffnen rechts daneben. Nichts überlappt.

| Was | Per Maus | Per Taste (Super = Windows-Taste) |
| --- | --- | --- |
| Programm starten | Knopf oben links oder Dock unten | `Super+Leertaste` |
| Alle Fenster überblicken | Maus in die Ecke oben links | `Super+Tab` |
| Zum Nachbarfenster | Fenster anklicken, 3-Finger-Wischen, `Super`+Mausrad | `Super+←/→` |
| Fenster schließen | Schließen-Knopf, oder Rechtsklick im Dock | `Super+Q` |
| Fenster verschieben | `Super` halten und ziehen, oder in der Übersicht ziehen | `Super+Shift+←/→` |
| Breite wechseln (⅓, ½, ⅔, voll) | – | `Super+R`, voll: `Super+F` |
| Vollbild | – | `Super+Shift+F` |
| WLAN, Ton, Bluetooth, Helligkeit | Symbol ganz rechts in der Leiste | – |
| Bildschirme / Fernseher anordnen | Einstellungen → Displays | `Super+,` öffnet die Einstellungen |
| Sperren / Ausschalten | Startmenü → Ein/Aus | `Super+L` / `Super+Esc` |
| Bildschirmfoto | – | `Druck` |
| Alle Tasten anzeigen | – | `Super+F1` |

Fernseher: Einstecken genügt, er erscheint als zweiter Bildschirm rechts
daneben. Spiegeln kann niri nicht direkt – dafür in die GNOME-Sitzung wechseln.

Manche Programme (Steam, JetBrains) haben unter niri keinen Schließen-Knopf:
`Super+Q` oder Rechtsklick auf das Symbol im Dock.

Aussehen der Leiste, des Docks und des Sperrbildschirms lässt sich in den
Einstellungen der Shell (`Super+,`) per Maus ändern. Zurück auf den
Auslieferungszustand: `amboss-shell-reset`.

## GNOME: das Dock

Unten am Bildschirm: Firefox, Terminal (Ghostty), Zed, Claude, Dateien, Steam,
Einstellungen, **Grafikmodus**, **System aktualisieren**. Alle weiteren
Programme: Raster-Symbol im Dock oder Super-Taste (Windows-Taste) und lostippen.

## Fernseher / zweiter Bildschirm

1. HDMI-Kabel einstecken – das Bild erscheint automatisch.
2. Anordnung, Spiegeln oder „nur Fernseher“: *Einstellungen → Bildschirme*.
   GNOME merkt sich die Wahl pro Gerät.
3. Ton über den Fernseher: Schnellmenü oben rechts → Pfeil neben dem
   Lautstärkeregler → HDMI-Ausgang wählen.

Am Netzteil geht der Laptop nicht von selbst in den Standby. Bleibt das Bild
schwarz: Grafikmodus darf nicht „Integrated“ sein (siehe unten).

Netflix läuft in Firefox. Unter Linux liefert Netflix höchstens 1080p, oft 720p.

## Updates

Es gibt drei Arten:

| Art | Was sich ändert | Auslösen |
| --- | --- | --- |
| Konfiguration | Was im Repo geändert wurde | Dock: *System aktualisieren* · `just sync` |
| Software | Alle Pakete, Kernel, Treiber, Sicherheitspatches | Rechtsklick auf *System aktualisieren* → *Zusätzlich alle Pakete aktualisieren* · `just update` |
| NixOS-Version | Sprung auf die nächste Ausgabe (halbjährlich) | Versionsnummern in `flake.nix` ändern, siehe [04](04-anpassen.md) |

- Ist der Software-Stand älter als 14 Tage, erscheint nach dem Anmelden eine
  Benachrichtigung mit dem Knopf *Jetzt aktualisieren*.
- Nach einem Software-Update ist `flake.lock` geändert. Committen und pushen,
  damit der Stand reproduzierbar bleibt.
- Kernel- und Treiber-Updates wirken erst nach einem Neustart.
- **Zurück:** `just rollback`, oder beim Start im Bootmenü einen älteren
  Eintrag wählen.

Aktualisiert sich selbst: Steam samt Spielen, Flatpaks (App *Software*),
JetBrains-Plugins, Zed-Erweiterungen. Rust: `rustup update`. Firmware/BIOS:
`fwupdmgr refresh && fwupdmgr update`.

Die JetBrains-IDEs selbst kommen über das Software-Update; der eingebaute
Updater funktioniert unter NixOS nicht.

## Programme installieren

| Weg | Wann | Im Repo? |
| --- | --- | --- |
| App *Software* (Flatpak) | Schnell mal etwas ausprobieren, Spotify, Discord | Nein |
| Eintrag in `modules/home/*.nix` + `just switch` | Alles, was nach einem Wipe wieder da sein soll | Ja |
| `nix shell nixpkgs#paketname` | Einmalig benutzen, ohne zu installieren | Nein |

Details: [04 – Anpassen](04-anpassen.md).

## Grafikmodus (Nvidia / MUX)

Dock-Symbol *Grafikmodus* (Dialog; Rechtsklick für Direktwahl) oder Schnellmenü
oben rechts.

| Modus | Wirkung | Aktiv nach |
| --- | --- | --- |
| Integrated | Nvidia aus, längste Akkulaufzeit; HDMI vermutlich ohne Bild | Ab-/Anmelden |
| Hybrid (Standard) | Interne Grafik, Nvidia bei Bedarf; HDMI funktioniert | Ab-/Anmelden |
| AsusMuxDgpu | Bildschirm direkt an Nvidia, höchste Leistung | Neustart |

Für Alltag, Programmieren und Fernseher: **Hybrid**. Der Dialog zeigt nur
Modi, die das Gerät unterstützt.

Lüfter-/Leistungsprofil: Schnellmenü → *Energiemodus*. Tastaturbeleuchtung und
Ladegrenze: `asusctl --help`.

## Steam

Starten, anmelden, dann einmalig *Steam → Einstellungen → Kompatibilität →
Steam Play für alle Titel aktivieren*. Damit laufen Windows-Spiele über Proton.

- Zickt ein Spiel: Rechtsklick → *Eigenschaften → Kompatibilität* → *GE-Proton* wählen.
- Mehr Leistung: Startoption `gamemoderun %command%`.
- FPS-Anzeige: Startoption `mangohud %command%`.
- Für anspruchsvolle Spiele Grafikmodus auf *AsusMuxDgpu* stellen.

Ob ein Spiel läuft: <https://www.protondb.com>. Spiele mit Kernel-Anti-Cheat
laufen meist nicht.

## Programmieren

- **Editoren:** Zed, IntelliJ IDEA, CLion, WebStorm, RustRover.
- **Vorhanden:** gcc, make, cmake, ninja, gdb, clangd · JDK, Maven, Gradle ·
  Node.js, pnpm, TypeScript · rustup · Docker, docker-compose, lazydocker.
- **Claude:** Dock-Symbol *Claude* öffnet claude.ai im Browser. Im Terminal
  startet `claude` im Projektordner Claude Code (beim ersten Mal anmelden).
  Eine Desktop-App gibt es für Linux nicht als Paket.
- **Rust einmalig:** `rustup default stable`.
- **Docker:** läuft ohne `sudo`. Aufräumen passiert wöchentlich automatisch.
- **Projektspezifische Versionen:** im Projekt eine `flake.nix` mit `devShell`
  und eine `.envrc` mit `use flake`, dann `direnv allow`. Beim Betreten des
  Ordners sind die Werkzeuge da.

## Terminal

fish schlägt beim Tippen Befehle aus dem Verlauf vor (→ übernimmt).
`Strg+R` durchsucht den Verlauf, `z ordnername` springt in oft benutzte Ordner.
Im Ordner `~/.nixos` zeigt `just` alle Kurzbefehle.

| Befehl | Wirkung |
| --- | --- |
| `just switch` | Änderungen im Repo anwenden |
| `just sync` | Stand aus Git holen und anwenden |
| `just update` | Alle Pakete aktualisieren und anwenden |
| `just test` | Anwenden ohne Eintrag im Bootmenü (Neustart = alter Stand) |
| `just rollback` | Zum vorherigen Stand |
| `just clean` | Stände älter als 14 Tage löschen |
| `just check` | Konfiguration prüfen |
| `just fmt` | Nix-Dateien formatieren |
| `just secrets-init` / `just secrets` | Secrets einrichten / bearbeiten |
| `just backup` | Backup sofort starten |
