# GNOME-Einstellungen und Erweiterungen – auf Mausbedienung ausgelegt.
{ pkgs, ... }:
{
  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.dash-to-dock; } # dauerhaft sichtbares Dock
      { package = pkgs.gnomeExtensions.appindicator; } # Tray-Icons
      # Ricing-Kandidaten für später:
      # { package = pkgs.gnomeExtensions.blur-my-shell; }
      # { package = pkgs.gnomeExtensions.just-perfection; }
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
        "org.gnome.Settings.desktop"
      ];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dock-fixed = false;
      click-action = "minimize";
    };
    # Netzbetrieb: nicht automatisch schlafen (Filmabend am Fernseher).
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };
}
