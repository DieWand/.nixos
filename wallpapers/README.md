# Wallpaper

Bild hier als `wallpaper.png` (oder `.jpg` / `.jpeg`) ablegen, dann:

```sh
git add wallpapers && just switch
```

Stylix setzt es als Hintergrund und leitet daraus das Farbschema für GNOME,
Terminal, Zed, Firefox, Boot-Bildschirm und Tastaturbeleuchtung ab. Ohne Bild
gilt das Platzhalter-Schema aus `modules/nixos/theme.nix`.

Weitere Bilder können hier liegen; aktiv ist immer `wallpaper.*`.
