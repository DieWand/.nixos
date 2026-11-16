# 04 – Anpassen

Grundregel: **Datei ändern → `just switch` → committen und pushen.**
Neue Dateien vor dem `switch` mit `git add` anmelden – Flakes sehen nur
Dateien, die Git kennt.

Erst ausprobieren: `just test` wendet an, ohne den Stand ins Bootmenü zu
übernehmen.

## Aufbau

```
flake.nix                       Quellen (nixpkgs, home-manager, disko, stylix, sops-nix, nixos-hardware)
flake.lock                      exakte Versionen (entsteht bei der Installation)
justfile                        Kurzbefehle
install.sh                      Neuinstallation
scripts/hardware-info.sh        sammelt Hardware-Daten

hosts/amboss/
  default.nix                   Modulauswahl, Hostname, Backup-Ziel
  hardware-configuration.nix    automatisch erzeugt – nicht von Hand ändern
  disko.nix                     Partitionierung

modules/nixos/                  Systemebene (braucht root)
  core.nix                      Boot, Nix, Sprache, Tastatur, Aufräumen
  desktop.nix                   GNOME, Ton, Drucken, Schriften, Flatpak
  niri.nix                      zweite Sitzung: niri + DankMaterialShell
  laptop.nix                    Energie, Bluetooth, Firmware, ASUS-Dienste
  nvidia.nix                    Nvidia-Treiber
  networking.nix                NetworkManager, Firewall
  users.nix                     Benutzerkonto, Gruppen
  dev.nix                       Docker
  gaming.nix                    Steam
  theme.nix                     Farben, Schriften, Cursor (Stylix)
  snapshots.nix                 Snapshots von /home
  secrets.nix                   verschlüsselte Secrets
  backup.nix                    restic-Backup

modules/home/                   Benutzerebene (alles unter ~)
  default.nix                   Liste der Module
  gnome.nix                     Dock, Erweiterungen, GNOME-Einstellungen
  niri.nix                      niri: Tasten, Rahmen, Shell-Thema
  browser.nix                   Firefox
  shell.nix                     fish, Prompt, Kürzel, CLI-Tools
  terminal.nix                  Ghostty
  git.nix                       Git
  editor.nix                    Zed, JetBrains
  dev.nix                       Compiler und Toolchains, direnv
  shortcuts.nix                 Update, Grafikmodus, Update-Erinnerung

dotfiles/                       rohe Config-Dateien ohne eigenes Modul
wallpapers/                     Hintergrundbilder
secrets/                        verschlüsselte Secrets
```

## Programm hinzufügen

1. Namen suchen: <https://search.nixos.org/packages> (Channel 26.05).
2. Eintragen:
   - Normale Programme: `home.packages` in der thematisch passenden Datei unter
     `modules/home/`.
   - Braucht es Systemrechte oder einen Dienst: unter `modules/nixos/`. Viele
     haben einen fertigen Schalter (`programs.xyz.enable = true;`) – suchen auf
     <https://search.nixos.org/options>.
3. `just switch`.

```nix
# modules/home/dev.nix
home.packages = with pkgs; [
  # …
  python3
];
```

Entfernen: Zeile löschen, `just switch`.

## Einstellungen ändern

| Was | Wo |
| --- | --- |
| Symbole im Dock | `favorite-apps` in `modules/home/gnome.nix` (Name der `.desktop`-Datei) |
| GNOME-Erweiterung | `programs.gnome-shell.extensions` in `gnome.nix` (`pkgs.gnomeExtensions.…`) |
| GNOME-Einstellung | `dconf.settings` in `gnome.nix`. Schlüssel finden: `dconf watch /` laufen lassen und die Einstellung in der GUI umstellen |
| Shell-Kürzel und Ersatzbefehle (`ls`→eza usw.) | `shellAbbrs`, `shellAliases` in `shell.nix` |
| Git-Name/E-Mail | `modules/home/git.nix` |
| Schwelle der Update-Erinnerung | `reminderDays` in `shortcuts.nix` |
| Anzahl Stände im Bootmenü | `configurationLimit` in `core.nix` |
| Snapshot-Aufbewahrung | `TIMELINE_LIMIT_*` in `snapshots.nix` |
| Backup-Ziel und Ausnahmen | `hosts/amboss/default.nix`, `backup.nix` |

Achtung: Was im Repo festgelegt ist, gewinnt. Stellst du so einen Wert in der
GNOME-Oberfläche um, setzt der nächste `switch` ihn zurück.

## Aussehen (Ricing)

Zentrale Stelle: `modules/nixos/theme.nix`. Stylix färbt GNOME, GTK-Programme,
Ghostty, Zed, Firefox, den Prompt, den Boot-Bildschirm und die
Tastaturbeleuchtung einheitlich.

**Farben:** `themes/hangar.yaml` – ein handabgestimmtes Schema passend zum
Wallpaper-Pack (fast schwarzer Petrol-Grund, Salbei-Grautöne, knochenweiße
Schrift, Signalrot und Petrol als Akzente). Einzelne Farben dort ändern,
`just switch`.

**Wallpaper:** Bilder nach `wallpapers/` legen, `git add wallpapers`,
`just switch`. niri wechselt durch alle; GNOME nutzt `wallpaper.png`
(Details: `wallpapers/README.md`).

| Was | Einstellung in `theme.nix` |
| --- | --- |
| Anderes Schema | `base16Scheme` – eigene Datei unter `themes/` oder ein fertiges aus <https://tinted-theming.github.io/tinted-gallery/> |
| Farben aus dem Wallpaper ableiten | Zeile `base16Scheme` löschen |
| Hell/Dunkel | `polarity` |
| Transparenz des Terminals | `opacity.terminal` |
| Symbole | `icons` (Papirus) |
| Schriften, Größen | `fonts` |
| Mauszeiger | `cursor` |
| Boot-Animation | Abschnitt `boot` (Plymouth) |

| Baustein | Wo |
| --- | --- |
| Milchglas (Blur my Shell), schlanke Leiste (Just Perfection), runde Fensterecken | `programs.gnome-shell.extensions` in `modules/home/gnome.nix`. Feineinstellung per Maus in der App *Erweiterungen* |
| Schwebendes Dock | `dash-to-dock` in `gnome.nix` |
| Firefox im GNOME-Stil | `firefoxGnomeTheme` in `modules/home/browser.nix` |
| Systeminfo beim Öffnen des Terminals | `interactiveShellInit` in `modules/home/shell.nix` |
| Tastaturbeleuchtung in Akzentfarbe | `amboss-keyboard-light` in `modules/home/shortcuts.nix` |

Hakt nach einem GNOME-Versionssprung eine Erweiterung: Zeile in `gnome.nix`
auskommentieren, `just switch`. Der Desktop selbst läuft auch ohne sie.

Einzelne Programme vom Färben ausnehmen: `stylix.targets.<name>.enable = false;`.
Die JetBrains-IDEs werden nicht erfasst – Theme dort in der IDE wählen.

## niri-Sitzung

| Was | Wo |
| --- | --- |
| Tasten, Fensterrahmen, Abstände, Regeln für einzelne Programme | `modules/home/niri.nix` (Abschnitt `niri/config.kdl`) |
| Tastenkürzel hinzufügen | `binds` in `niri.nix`. Der Text hinter `hotkey-overlay-title` erscheint in der Übersicht (`Super+K`) – immer mit angeben |
| Hinweis in der Leiste | `dotfiles/dms-plugins/ambossKeys/` |
| Farben der Shell (Leiste, Dock, Menüs) | `shellTheme` in `niri.nix` – speist sich aus `themes/hangar.yaml` |
| Startwerte der Shell (Schrift, Widgets der Leiste, Dock) | `shellSettings` in `niri.nix` |
| Pakete, Shell an/aus | `modules/nixos/niri.nix` |

Die Shell (DankMaterialShell) speichert Änderungen aus ihrer
Einstellungs-Oberfläche in `~/.config/DankMaterialShell/settings.json`. Diese
Datei wird nur einmal mit den Startwerten angelegt und danach nicht mehr
überschrieben – Klick-Änderungen bleiben also erhalten, stehen aber nicht im
Repo. Geänderte Startwerte aus dem Repo übernehmen: `amboss-shell-reset`,
dann ab- und anmelden.

Die niri-Konfiguration prüfen, bevor man sie anwendet: `niri validate`.

## Rohe Dotfiles

Für Programme ohne Home-Manager-Modul: Datei nach `dotfiles/` legen und verlinken:

```nix
xdg.configFile."programm/config.toml".source = ../../dotfiles/programm/config.toml;
```

## Eigene Verknüpfung im Dock

Muster in `modules/home/shortcuts.nix`: Skript mit `pkgs.writeShellApplication`,
Eintrag unter `xdg.desktopEntries`, Name in `favorite-apps` (`gnome.nix`).

## Auf die nächste NixOS-Version wechseln

Halbjährlich (Mai/November). In `flake.nix` die drei Versionsangaben
(`nixos-26.05`, `release-26.05` bei home-manager und stylix) auf die neue
Version ändern, dann `just update`. `system.stateVersion` und
`home.stateVersion` **nicht** ändern. Meldet der Build umbenannte Optionen:
der Meldung folgen. Bei Problemen `just rollback`.

## Zweites Gerät

Ordner `hosts/<name>/` mit eigener `default.nix`, `disko.nix` und
`hardware-configuration.nix` anlegen, in `flake.nix` einen weiteren Eintrag
unter `nixosConfigurations`. Die Module unter `modules/` werden geteilt.
