# niri-Sitzung: Fensterverwaltung, Tasten, Aussehen der Shell.
# Auf Mausbedienung ausgelegt: Dock unten, Startknopf oben links, Übersicht
# über die Bildschirmecke oben links, Schließen-Knopf an den Fenstern.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;
  mono = config.stylix.fonts.monospace.name;

  # Alle Bilder aus wallpapers/ landen als Ordner unter ~/.local/share/wallpapers.
  # Die Shell wechselt automatisch durch diesen Ordner.
  isImage = n: builtins.match ".*\\.(png|jpg|jpeg|webp)" (lib.toLower n) != null;
  wallpaperNames = lib.sort (a: b: a < b) (
    builtins.filter isImage (builtins.attrNames (builtins.readDir ../../wallpapers))
  );
  wallpaperSrc = builtins.path {
    path = ../../wallpapers;
    name = "wallpapers";
    filter = path: type: type == "regular" && isImage (baseNameOf path);
  };
  wallpaperDir = "${config.xdg.dataHome}/wallpapers";
  # Startbild: wallpaper.* falls vorhanden, sonst das erste Bild.
  firstWallpaper =
    let
      preferred = builtins.filter (n: lib.hasPrefix "wallpaper." n) wallpaperNames;
    in
    if preferred != [ ] then
      builtins.head preferred
    else if wallpaperNames != [ ] then
      builtins.head wallpaperNames
    else
      null;
  # Wechsel-Intervall in Sekunden.
  wallpaperInterval = 1800;

  dms = cmd: ''spawn "dms" "ipc" "call" ${lib.concatMapStringsSep " " (a: ''"${a}"'') cmd}'';

  # Farbschema der Shell – aus themes/hangar.yaml abgeleitet.
  shellTheme =
    let
      theme = {
        name = "Hangar";
        primary = c.base0C; # Petrol-Leuchten
        primaryText = c.base00;
        primaryContainer = c.base02;
        secondary = c.base08; # Signalrot
        surface = c.base00;
        surfaceText = c.base05;
        surfaceVariant = c.base01;
        surfaceVariantText = c.base04;
        surfaceTint = c.base0C;
        background = c.base00;
        backgroundText = c.base05;
        outline = c.base03;
        surfaceContainer = c.base01;
        surfaceContainerHigh = c.base02;
        surfaceContainerHighest = c.base03;
        error = c.base08;
        warning = c.base09;
        info = c.base0D;
      };
    in
    pkgs.writeText "dms-hangar-theme.json" (
      builtins.toJSON {
        dark = theme;
        light = theme;
      }
    );

  # Startwerte der Shell. Werden nur angelegt, wenn noch keine Einstellungen
  # existieren – danach gehört die Datei der Einstellungs-Oberfläche der Shell.
  # Zurück auf diese Werte: `amboss-shell-reset`.
  shellSettings = pkgs.writeText "dms-settings.json" (
    builtins.toJSON {
      configVersion = 5;
      currentThemeName = "custom";
      customThemeFile = "${config.xdg.configHome}/DankMaterialShell/hangar-theme.json";
      fontFamily = mono;
      monoFontFamily = mono;
      cornerRadius = 0; # eckig statt rund
      use24HourClock = true;
      showSeconds = true;
      weatherEnabled = false;
      popupTransparency = 0.96;
      dockTransparency = 0.85;
      showDock = true;
      dockAutoHide = false;
      dockPosition = 1; # unten
      showLauncherButton = true;
      lockBeforeSuspend = true;
      barConfigs = [
        {
          id = "default";
          name = "Main Bar";
          enabled = true;
          position = 0; # oben
          screenPreferences = [ "all" ];
          showOnLastDisplay = true;
          leftWidgets = [
            "launcherButton"
            "workspaceSwitcher"
            "focusedWindow"
          ];
          centerWidgets = [ "clock" ];
          rightWidgets = [
            "ambossKeys" # Hinweis „SUPER+K // TASTEN“
            "systemTray"
            "clipboard"
            "cpuUsage"
            "cpuTemp"
            "memUsage"
            "notificationButton"
            "battery"
            "controlCenterButton"
          ];
          spacing = 0;
          innerPadding = 4;
          transparency = 0.9;
          widgetTransparency = 0.0;
          squareCorners = true;
          borderEnabled = true;
          borderColor = "outline";
          borderOpacity = 1.0;
          borderThickness = 1;
          widgetOutlineEnabled = false;
          visible = true;
        }
      ];
    }
  );

  shellPlugins = pkgs.writeText "dms-plugin-settings.json" (
    builtins.toJSON { ambossKeys.enabled = true; }
  );

  shellSession = pkgs.writeText "dms-session.json" (
    builtins.toJSON {
      isLightMode = false;
      wallpaperTransition = "fade";
      wallpaperCyclingEnabled = true;
      wallpaperCyclingMode = "interval";
      wallpaperCyclingInterval = wallpaperInterval;
    }
  );

  seed = pkgs.writeShellApplication {
    name = "amboss-shell-seed";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      force="''${1:-}"
      cfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/DankMaterialShell"
      mkdir -p "$cfg/DankMaterialShell" "$cfg/niri/dms" "$state"

      # Diese Dateien bindet die niri-Konfiguration ein; die Shell füllt sie
      # (z. B. die Bildschirm-Anordnung aus ihren Einstellungen).
      for f in outputs cursor; do
        [ -e "$cfg/niri/dms/$f.kdl" ] || : > "$cfg/niri/dms/$f.kdl"
      done

      if [ "$force" = "--force" ] || [ ! -e "$cfg/DankMaterialShell/settings.json" ]; then
        install -m 644 ${shellSettings} "$cfg/DankMaterialShell/settings.json"
      fi
      if [ "$force" = "--force" ] || [ ! -e "$cfg/DankMaterialShell/plugin_settings.json" ]; then
        install -m 644 ${shellPlugins} "$cfg/DankMaterialShell/plugin_settings.json"
      fi
      if [ "$force" = "--force" ] || [ ! -e "$state/session.json" ]; then
        install -m 644 ${shellSession} "$state/session.json"
      fi

      # Startbild setzen, wenn noch keins gewählt ist oder das gewählte fehlt.
      first="${if firstWallpaper != null then "${wallpaperDir}/${firstWallpaper}" else ""}"
      if [ -n "$first" ]; then
        current="$(jq -r '.wallpaperPath // ""' "$state/session.json" 2>/dev/null || echo "")"
        if [ -z "$current" ] || [ ! -e "$current" ]; then
          tmp="$(mktemp)"
          jq --arg p "$first" '.wallpaperPath = $p | .wallpaperPathDark = $p | .wallpaperPathLight = $p' \
            "$state/session.json" > "$tmp" && install -m 644 "$tmp" "$state/session.json"
          rm -f "$tmp"
        fi
      fi
    '';
  };

  reset = pkgs.writeShellApplication {
    name = "amboss-shell-reset";
    text = ''
      ${seed}/bin/amboss-shell-seed --force
      echo "Shell-Einstellungen zurückgesetzt. Einmal ab- und anmelden."
    '';
  };
in
{
  home.packages = [ reset ];

  xdg.configFile."DankMaterialShell/hangar-theme.json".source = shellTheme;
  xdg.dataFile."wallpapers".source = wallpaperSrc;

  home.activation.ambossShellSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${seed}/bin/amboss-shell-seed
  '';

  xdg.configFile."niri/config.kdl".text = ''
    // Verwaltet in ~/.nixos/modules/home/niri.nix – hier nicht von Hand ändern.

    input {
        keyboard {
            xkb {
                layout "de"
            }
            numlock
        }
        touchpad {
            tap
            natural-scroll
            dwt
        }
        mouse {
            accel-profile "flat"
        }
    }

    // Maus in die Ecke oben links = Übersicht aller Fenster.
    gestures {
        hot-corners {
            top-left
        }
    }

    // Bildschirm-Anordnung und Mauszeiger aus den Einstellungen der Shell.
    include "dms/outputs.kdl"
    include "dms/cursor.kdl"

    layout {
        gaps 14
        background-color "transparent"
        center-focused-column "on-overflow"
        always-center-single-column

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }
        default-column-width { proportion 0.5; }

        // Dünner Rahmen wie die Zielmarkierungen in den Wallpapern:
        // aktives Fenster signalrot, alle anderen salbeigrau.
        focus-ring {
            off
        }
        border {
            width 2
            active-color "${c.base08}"
            inactive-color "${c.base03}"
            urgent-color "${c.base09}"
        }
        shadow {
            off
        }
        tab-indicator {
            active-color "${c.base08}"
            inactive-color "${c.base03}"
        }
        insert-hint {
            color "${c.base0C}80"
        }
    }

    overview {
        backdrop-color "${c.base00}"
        workspace-shadow {
            off
        }
    }

    // Wallpaper der Shell liegt hinter der Übersicht.
    layer-rule {
        match namespace="^quickshell$"
        place-within-backdrop true
    }

    cursor {
        xcursor-theme "${config.stylix.cursor.name}"
        xcursor-size ${toString config.stylix.cursor.size}
    }

    environment {
        XDG_CURRENT_DESKTOP "niri"
        NIXOS_OZONE_WL "1"
        QT_QPA_PLATFORM "wayland;xcb"
    }

    hotkey-overlay {
        skip-at-startup
    }

    screenshot-path "~/Bilder/Bildschirmfotos/%Y-%m-%d %H-%M-%S.png"

    spawn-at-startup "dms" "run"

    animations {
        window-open {
            duration-ms 140
            curve "ease-out-expo"
        }
        window-close {
            duration-ms 120
            curve "ease-out-quad"
        }
    }

    window-rule {
        draw-border-with-background false
        clip-to-geometry true
    }
    window-rule {
        match app-id=r#"^org\.gnome\.Calculator$"#
        match app-id=r#"^xdg-desktop-portal"#
        match app-id=r#"^zenity$"#
        match app-id=r#"org.quickshell$"#
        match app-id=r#"com.danklinux.dms$"#
        open-floating true
    }
    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }
    window-rule {
        match app-id=r#"^steam$"# title=r#"^notificationtoasts_\d+_desktop$"#
        default-floating-position x=10 y=10 relative-to="bottom-right"
        open-focused false
    }
    // Spiele im Vollbild ohne Rahmen.
    window-rule {
        match app-id=r#"^steam_app_"#
        open-fullscreen true
        border {
            off
        }
    }

    // Wenige Tasten – alles Wichtige geht auch per Maus.
    // Mod = Super-Taste (Windows-Taste).
    // EINE Taste merken: Super+K zeigt alle anderen (durchsuchbar).
    // Die Texte hinter hotkey-overlay-title erscheinen in dieser Übersicht.
    binds {
        Mod+K hotkey-overlay-title="Tastenübersicht (diese Liste)" { ${dms [ "keybinds" "toggle" "niri" ]}; }
        Mod+F1 hotkey-overlay-title="Tastenübersicht (einfach, Notfall)" { show-hotkey-overlay; }

        Mod+Space hotkey-overlay-title="Startmenü: Programme suchen und starten" { ${dms [ "spotlight" "toggle" ]}; }
        Mod+T hotkey-overlay-title="Terminal" { spawn "ghostty"; }
        Mod+B hotkey-overlay-title="Browser" { spawn "firefox"; }
        Mod+E hotkey-overlay-title="Dateien" { spawn "nautilus"; }
        Mod+Comma hotkey-overlay-title="Einstellungen der Oberfläche" { ${dms [ "settings" "toggle" ]}; }
        Mod+V hotkey-overlay-title="Zwischenablage-Verlauf" { ${dms [ "clipboard" "toggle" ]}; }
        Mod+W hotkey-overlay-title="Nächstes Wallpaper" { ${dms [ "wallpaper" "next" ]}; }
        Mod+Shift+W hotkey-overlay-title="Vorheriges Wallpaper" { ${dms [ "wallpaper" "prev" ]}; }
        Mod+L hotkey-overlay-title="Bildschirm sperren" { ${dms [ "lock" "lock" ]}; }
        Mod+Escape hotkey-overlay-title="Ausschalten / Neustart / Abmelden" { ${dms [ "powermenu" "toggle" ]}; }

        Mod+Q hotkey-overlay-title="Fenster schließen" { close-window; }
        Mod+Tab hotkey-overlay-title="Übersicht aller Fenster" { toggle-overview; }
        // Alt+Tab (Fensterwechsel) bringt niri von Haus aus mit.

        Mod+Left hotkey-overlay-title="Zum Fenster links" { focus-column-left; }
        Mod+Right hotkey-overlay-title="Zum Fenster rechts" { focus-column-right; }
        Mod+Up hotkey-overlay-title="Fenster / Arbeitsfläche darüber" { focus-window-or-workspace-up; }
        Mod+Down hotkey-overlay-title="Fenster / Arbeitsfläche darunter" { focus-window-or-workspace-down; }
        Mod+Shift+Left hotkey-overlay-title="Fenster nach links schieben" { move-column-left; }
        Mod+Shift+Right hotkey-overlay-title="Fenster nach rechts schieben" { move-column-right; }
        Mod+Shift+Up hotkey-overlay-title="Fenster nach oben schieben" { move-window-up-or-to-workspace-up; }
        Mod+Shift+Down hotkey-overlay-title="Fenster nach unten schieben" { move-window-down-or-to-workspace-down; }

        Mod+R hotkey-overlay-title="Fensterbreite wechseln (1/3, 1/2, 2/3, voll)" { switch-preset-column-width; }
        Mod+F hotkey-overlay-title="Fenster auf volle Breite" { maximize-column; }
        Mod+Shift+F hotkey-overlay-title="Vollbild" { fullscreen-window; }
        Mod+Shift+V hotkey-overlay-title="Fenster frei schwebend an/aus" { toggle-window-floating; }

        // Maus: Super + Mausrad blättert durch Fenster und Arbeitsflächen.
        Mod+WheelScrollDown cooldown-ms=150 hotkey-overlay-title="Zum Fenster rechts (Mausrad)" { focus-column-right; }
        Mod+WheelScrollUp cooldown-ms=150 hotkey-overlay-title="Zum Fenster links (Mausrad)" { focus-column-left; }
        Mod+Shift+WheelScrollDown cooldown-ms=150 hotkey-overlay-title="Arbeitsfläche darunter (Mausrad)" { focus-workspace-down; }
        Mod+Shift+WheelScrollUp cooldown-ms=150 hotkey-overlay-title="Arbeitsfläche darüber (Mausrad)" { focus-workspace-up; }

        Print hotkey-overlay-title="Bildschirmfoto (Bereich wählen)" { screenshot; }
        Mod+Print hotkey-overlay-title="Bildschirmfoto (ganzer Bildschirm)" { screenshot-screen; }

        XF86AudioRaiseVolume allow-when-locked=true hotkey-overlay-title="Lauter" { spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true hotkey-overlay-title="Leiser" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute allow-when-locked=true hotkey-overlay-title="Ton aus/an" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute allow-when-locked=true hotkey-overlay-title="Mikrofon aus/an" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86MonBrightnessUp allow-when-locked=true hotkey-overlay-title="Heller" { spawn "brightnessctl" "set" "5%+"; }
        XF86MonBrightnessDown allow-when-locked=true hotkey-overlay-title="Dunkler" { spawn "brightnessctl" "set" "5%-"; }

        Mod+Shift+E hotkey-overlay-title="Abmelden (Notausgang)" { quit; }
    }
  '';
}
