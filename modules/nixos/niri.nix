# Zweite Desktop-Sitzung: niri (Fenstermanager) + DankMaterialShell (Leiste,
# Dock, Startmenü, Schnelleinstellungen, Sperrbildschirm).
# Auswahl am Anmeldebildschirm über das Zahnrad unten rechts; GNOME bleibt
# unverändert als Rückfallebene.
{ pkgs, ... }:
{
  programs.niri.enable = true;

  programs.dms-shell = {
    enable = true;
    # Nicht über systemd starten – sonst liefe die Shell auch in GNOME.
    # Gestartet wird sie aus der niri-Konfiguration (modules/home/niri.nix).
    systemd.enable = false;
    # Farben kommen fest aus dem eigenen Schema, nicht aus dem Wallpaper.
    enableDynamicTheming = false;
    enableCalendarEvents = false;

    # Eigenes Leisten-Element: Hinweis auf die Tastenübersicht (Super+K).
    plugins.ambossKeys.src = ../../dotfiles/dms-plugins/ambossKeys;
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite # X11-Programme (Steam, JetBrains) unter niri
    brightnessctl # Helligkeitstasten
    departure-mono # Pixel-Schrift im HUD-Stil
  ];

  fonts.packages = [ pkgs.departure-mono ];
}
