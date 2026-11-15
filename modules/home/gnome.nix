# GNOME-Einstellungen und Erweiterungen – auf Mausbedienung ausgelegt.
{ pkgs, ... }:
{
  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.dash-to-dock; } # dauerhaft sichtbares Dock
      { package = pkgs.gnomeExtensions.appindicator; } # Tray-Icons
      { package = pkgs.gnomeExtensions.gpu-supergfxctl-switch; } # Grafikmodus per Klick

      # Aussehen
      { package = pkgs.gnomeExtensions.blur-my-shell; } # Milchglas für Leiste, Dock, Übersicht
      { package = pkgs.gnomeExtensions.just-perfection; } # schlankere Leiste
      # Die beiden folgenden sind am ehesten betroffen, wenn nach einem
      # GNOME-Versionssprung etwas hakt – dann einfach auskommentieren.
      { package = pkgs.gnomeExtensions.rounded-window-corners-reborn; }
      { package = pkgs.gnomeExtensions.burn-my-windows; } # Effekte beim Öffnen/Schließen
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      # Minimieren/Maximieren-Knöpfe wie gewohnt.
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
      clock-show-weekday = true;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "com.mitchellh.ghostty.desktop"
        "dev.zed.Zed.desktop"
        "org.gnome.Nautilus.desktop"
        "steam.desktop"
        "org.gnome.Settings.desktop"
        "amboss-gpu-mode.desktop"
        "amboss-update.desktop"
      ];
    };
    # Schwebendes, abgerundetes Dock; weicht Fenstern aus und kommt zurück,
    # wenn die Maus an den unteren Rand fährt.
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dock-fixed = false;
      extend-height = false;
      autohide = true;
      intellihide = true;
      custom-theme-shrink = true;
      dash-max-icon-size = 48;
      transparency-mode = "FIXED";
      background-opacity = 0.35;
      running-indicator-style = "DOTS";
      show-trash = false;
      click-action = "minimize";
    };
    "org/gnome/shell/extensions/just-perfection" = {
      startup-status = 0; # nach dem Anmelden direkt der Desktop statt der Übersicht
      accessibility-menu = false;
      world-clock = false;
      window-demands-attention-focus = true;
    };
    # Netzbetrieb: nicht automatisch schlafen (Filmabend am Fernseher).
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };
}
