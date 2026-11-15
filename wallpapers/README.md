# Wallpaper

Bild hier als `wallpaper.png` (oder `.jpg` / `.jpeg`) ablegen, dann:

```sh
git add wallpapers && just switch
```

Stylix setzt es als Hintergrund. Die Farben kommen aus dem handabgestimmten
Schema `themes/hangar.yaml`; sollen sie stattdessen aus dem Bild abgeleitet
werden, in `modules/nixos/theme.nix` die Zeile `base16Scheme` löschen.

Weitere Bilder können hier liegen; aktiv ist immer `wallpaper.*`.
