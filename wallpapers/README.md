# Wallpaper

Alle Bilder in diesem Ordner (`.png`, `.jpg`, `.jpeg`, `.webp`) hier ablegen, dann:

```sh
git add wallpapers && just switch
```

- **niri-Sitzung:** wechselt alle 30 Minuten durch sämtliche Bilder dieses
  Ordners. Sofort weiter/zurück: `Super+W` / `Super+Shift+W`. Intervall ändern:
  `wallpaperInterval` in `modules/home/niri.nix` oder per Maus in den
  Einstellungen der Shell (`Super+,`).
- **GNOME-Sitzung und Farbableitung:** benutzen nur die Datei `wallpaper.png`
  (oder `.jpg`/`.jpeg`). Sie ist auch das Startbild in niri.

Die Farben kommen aus dem handabgestimmten Schema `themes/hangar.yaml`; sollen
sie stattdessen aus `wallpaper.*` abgeleitet werden, in
`modules/nixos/theme.nix` die Zeile `base16Scheme` löschen.
