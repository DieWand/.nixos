# Ricing-Zentrale: Stylix färbt GNOME, GTK, Terminal, Zed, Firefox usw.
# aus EINEM Farbschema. Design wird später festgelegt – hier nur das Gerüst.
{ pkgs, lib, ... }:
let
  # Wallpaper: Datei als wallpapers/wallpaper.png (oder .jpg/.jpeg) ablegen.
  # Sobald sie da ist, leitet Stylix das komplette Farbschema aus dem Bild ab.
  wallpaper = lib.findFirst builtins.pathExists null [
    ../../wallpapers/wallpaper.png
    ../../wallpapers/wallpaper.jpg
    ../../wallpapers/wallpaper.jpeg
  ];
in
{
  stylix = {
    enable = true;
    polarity = "dark";

    # Farben: aus dem Wallpaper, sonst dieses Schema als Platzhalter.
    # Festes Schema trotz Wallpaper erzwingen: mkIf-Bedingung entfernen.
    # Alle Schemata: https://tinted-theming.github.io/tinted-gallery/
    image = lib.mkIf (wallpaper != null) wallpaper;
    base16Scheme = lib.mkIf (
      wallpaper == null
    ) "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    # Leicht durchscheinendes Terminal.
    opacity.terminal = 0.9;

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        terminal = 12;
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };

  # Boot: Logo und grafische Passwortabfrage im Farbschema statt Textzeilen.
  boot = {
    plymouth.enable = true;
    initrd.systemd.enable = true;
    initrd.verbose = false;
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];
  };
}
