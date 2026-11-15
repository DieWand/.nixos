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
| Shell-Kürzel | `shellAbbrs` in `shell.nix` |
| Git-Name/E-Mail | `modules/home/git.nix` |
| Schwelle der Update-Erinnerung | `reminderDays` in `shortcuts.nix` |
| Anzahl Stände im Bootmenü | `configurationLimit` in `core.nix` |
| Snapshot-Aufbewahrung | `TIMELINE_LIMIT_*` in `snapshots.nix` |
| Backup-Ziel und Ausnahmen | `hosts/amboss/default.nix`, `backup.nix` |

Achtung: Was im Repo festgelegt ist, gewinnt. Stellst du so einen Wert in der
GNOME-Oberfläche um, setzt der nächste `switch` ihn zurück.

## Aussehen (Ricing)

Zentrale Stelle: `modules/nixos/theme.nix`.

| Was | Einstellung |
| --- | --- |
| Farbschema | `base16Scheme` – Dateiname aus <https://tinted-theming.github.io/tinted-gallery/> |
| Hell/Dunkel | `polarity` |
| Hintergrundbild | Datei nach `wallpapers/`, `image = ../../wallpapers/datei.png;` (ohne `base16Scheme` leitet Stylix die Farben aus dem Bild ab) |
| Schriften, Größen | `fonts` |
| Mauszeiger | `cursor` |

Stylix färbt GNOME, GTK-Programme, Ghostty, Zed, Firefox und den Prompt
einheitlich. Einzelne Programme ausnehmen: `stylix.targets.<name>.enable = false;`.
Die JetBrains-IDEs werden nicht erfasst – Theme dort in der IDE wählen.

Weitere Stellschrauben: GNOME-Erweiterungen (z. B. Blur my Shell, Just
Perfection – in `gnome.nix` vorbereitet), `programs.starship.settings`,
Ghostty-`settings`, `fastfetch`.

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
