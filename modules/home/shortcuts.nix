# Verknüpfungen für die App-Übersicht / das Dock – alles per Maus bedienbar.
{
  pkgs,
  inputs,
  config,
  ...
}:
let
  # Ab wie vielen Tagen an ein Software-Update erinnert wird.
  reminderDays = 14;

  # Holt den neuesten Stand aus Git und wendet ihn an.
  update = pkgs.writeShellApplication {
    name = "amboss-update";
    runtimeInputs = [ pkgs.git ];
    text = ''
      finish() {
        echo
        read -r -p "Fertig – Enter schließt das Fenster. " _ || true
      }
      trap finish EXIT

      cd "$HOME/.nixos"

      echo "==> Neuesten Stand aus Git holen"
      git pull --ff-only

      if [ "''${1:-}" = "--full" ]; then
        echo "==> Paketquellen aktualisieren"
        nix flake update
      fi

      echo "==> System anwenden (fragt nach dem Passwort)"
      sudo nixos-rebuild switch --flake .#amboss

      echo
      echo "✔ System ist aktuell."
      if [ "''${1:-}" = "--full" ] && ! git diff --quiet flake.lock; then
        echo "Hinweis: flake.lock wurde geändert – bei Gelegenheit committen und pushen."
      fi
    '';
  };

  # Grafikmodus-Auswahl als Dialog (zeigt nur, was das Gerät unterstützt).
  gpuMode = pkgs.writeShellApplication {
    name = "amboss-gpu-mode";
    runtimeInputs = [
      pkgs.zenity
      pkgs.supergfxctl
      pkgs.gnome-session
    ];
    text = ''
      describe() {
        case "$1" in
          Integrated) echo "Sparsam – nur interne Grafik, Nvidia aus" ;;
          Hybrid) echo "Standard – Nvidia nur bei Bedarf (Alltag, Fernseher)" ;;
          AsusMuxDgpu) echo "Leistung – Bildschirm direkt an Nvidia (Neustart nötig)" ;;
          *) echo "" ;;
        esac
      }

      current="$(supergfxctl -g)"
      target="''${1:-}"

      if [ -z "$target" ]; then
        rows=()
        for mode in $(supergfxctl -s | tr -d '[],'); do
          if [ "$mode" = "$current" ]; then rows+=(TRUE); else rows+=(FALSE); fi
          rows+=("$mode" "$(describe "$mode")")
        done
        target="$(zenity --list --radiolist --title="Grafikmodus" \
          --text="Aktuell: $current" --width=560 --height=320 \
          --column="" --column="Modus" --column="Beschreibung" "''${rows[@]}")" || exit 0
      fi

      [ -z "$target" ] && exit 0
      [ "$target" = "$current" ] && exit 0

      if ! out="$(supergfxctl -m "$target" 2>&1)"; then
        zenity --error --title="Grafikmodus" --text="Umschalten fehlgeschlagen:\n$out"
        exit 1
      fi

      if [ "$target" = "AsusMuxDgpu" ] || [ "$current" = "AsusMuxDgpu" ]; then
        if zenity --question --title="Grafikmodus" \
          --text="Modus '$target' wird nach einem Neustart aktiv.\n\nJetzt neu starten?"; then
          systemctl reboot
        fi
      else
        zenity --info --title="Grafikmodus" \
          --text="Modus '$target' wird nach dem Ab- und Anmelden aktiv."
        gnome-session-quit --logout || true
      fi
    '';
  };

  # Erinnert nach dem Anmelden, wenn der Software-Stand zu alt ist.
  # Der Zeitstempel des installierten Paketstands wird beim Bauen eingesetzt,
  # nach jedem Update ist die Erinnerung also automatisch wieder ruhig.
  updateReminder = pkgs.writeShellApplication {
    name = "amboss-update-reminder";
    runtimeInputs = [
      pkgs.libnotify
      pkgs.ghostty
      update
    ];
    text = ''
      installed=${toString inputs.nixpkgs.lastModified}
      age=$(( ($(date +%s) - installed) / 86400 ))
      [ "$age" -lt ${toString reminderDays} ] && exit 0

      action="$(notify-send --wait \
        --app-name="System" --icon=system-software-update --urgency=critical \
        --action="update=Jetzt aktualisieren" \
        "Software-Update empfohlen" \
        "Der Software-Stand ist $age Tage alt.")" || exit 0

      if [ "$action" = "update" ]; then
        ghostty -e amboss-update --full
      fi
    '';
  };
in
{
  systemd.user.services.amboss-update-reminder = {
    Unit.Description = "Erinnerung an Software-Updates";
    Service = {
      Type = "simple";
      ExecStart = "${updateReminder}/bin/amboss-update-reminder";
    };
  };

  # Tastaturbeleuchtung in der Akzentfarbe des Farbschemas (nur RGB-Tastaturen;
  # schlägt auf anderen Geräten folgenlos fehl).
  systemd.user.services.amboss-keyboard-light = {
    Unit = {
      Description = "Tastaturbeleuchtung im Farbschema";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "-${pkgs.asusctl}/bin/asusctl aura effect static -c ${config.lib.stylix.colors.base0D}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Eine Minute nach dem Anmelden, danach einmal täglich.
  systemd.user.timers.amboss-update-reminder = {
    Unit.Description = "Erinnerung an Software-Updates";
    Timer = {
      OnActiveSec = "1min";
      OnUnitInactiveSec = "1d";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.packages = [
    update
    gpuMode
  ];

  xdg.desktopEntries = {
    amboss-update = {
      name = "System aktualisieren";
      comment = "Neuesten Stand aus Git holen und anwenden";
      icon = "system-software-update";
      exec = "ghostty -e amboss-update";
      categories = [ "System" ];
      actions.full = {
        name = "Zusätzlich alle Pakete aktualisieren";
        exec = "ghostty -e amboss-update --full";
      };
    };

    amboss-gpu-mode = {
      name = "Grafikmodus";
      comment = "Zwischen sparsam, Standard und Nvidia-Leistung (MUX) umschalten";
      icon = "video-display";
      exec = "amboss-gpu-mode";
      categories = [ "System" ];
      # Rechtsklick auf das Symbol im Dock:
      actions = {
        integrated = {
          name = "Sparsam (Integrated)";
          exec = "amboss-gpu-mode Integrated";
        };
        hybrid = {
          name = "Standard (Hybrid)";
          exec = "amboss-gpu-mode Hybrid";
        };
        mux = {
          name = "Leistung (Nvidia / MUX)";
          exec = "amboss-gpu-mode AsusMuxDgpu";
        };
      };
    };
  };
}
