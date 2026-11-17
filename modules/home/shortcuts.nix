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
  #   amboss-update           Stand aus Git holen und anwenden
  #   amboss-update --full    zusätzlich alle Pakete aktualisieren
  #   --pause                 am Ende auf Enter warten (für das Dock-Symbol)
  # Lokale Änderungen auf dem Laptop werden vorher automatisch committet,
  # damit das Holen nie daran scheitert; am Ende wird alles hochgeladen.
  update = pkgs.writeShellApplication {
    name = "amboss-update";
    runtimeInputs = [
      pkgs.git
      pkgs.gh
    ];
    text = ''
      full=0
      pause=0
      for arg in "$@"; do
        case "$arg" in
          --full) full=1 ;;
          --pause) pause=1 ;;
        esac
      done

      if [ "$pause" -eq 1 ]; then
        finish() {
          echo
          read -r -p "Fertig – Enter schließt das Fenster. " _ || true
        }
        trap finish EXIT
      fi

      cd "$HOME/.nixos"

      if [ -n "$(git status --porcelain)" ]; then
        echo "==> Lokale Änderungen sichern"
        git status --short
        git add -A
        git commit -q -m "amboss: lokale Änderungen vom $(date +%F)"
      fi

      echo "==> Neuesten Stand aus Git holen"
      if ! git pull --rebase; then
        if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
          git rebase --abort || true
          echo
          echo "✘ Lokale Änderungen widersprechen dem Stand im Repo."
          echo "  Nichts wurde angewendet. Ausgabe von 'git status' an Claude geben"
          echo "  oder in docs/06-fehlerbehebung.md nachsehen."
        else
          echo
          echo "✘ Repo nicht erreichbar (Internet?). Nichts wurde angewendet."
        fi
        exit 1
      fi

      if [ "$full" -eq 1 ]; then
        echo "==> Paketquellen aktualisieren"
        nix flake update
        if [ -n "$(git status --porcelain flake.lock)" ]; then
          git add flake.lock
          git commit -q -m "amboss: Pakete aktualisiert ($(date +%F))"
        fi
      fi

      echo "==> System anwenden (fragt nach dem Passwort)"
      sudo nixos-rebuild switch --flake .#amboss

      if [ "$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)" -gt 0 ]; then
        echo "==> Lokale Änderungen hochladen"
        if ! git push; then
          echo
          echo "Hinweis: Hochladen fehlgeschlagen. Einmalig 'gh auth login' ausführen,"
          echo "danach erneut aktualisieren. Das System selbst ist trotzdem aktuell."
        fi
      fi

      echo
      echo "✔ System ist aktuell."
    '';
  };

  # Grafikmodus-Auswahl als Dialog (zeigt nur, was das Gerät unterstützt).
  gpuMode = pkgs.writeShellApplication {
    name = "amboss-gpu-mode";
    runtimeInputs = [
      pkgs.zenity
      pkgs.supergfxctl
      pkgs.gnome-session
      pkgs.niri
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
        gnome-session-quit --logout || niri msg action quit || true
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
        ghostty -e amboss-update --pause --full
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
      ExecStart = "-${pkgs.asusctl}/bin/asusctl aura effect static -c ${config.lib.stylix.colors.base0C}";
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
      exec = "ghostty -e amboss-update --pause";
      categories = [ "System" ];
      actions.full = {
        name = "Zusätzlich alle Pakete aktualisieren";
        exec = "ghostty -e amboss-update --pause --full";
      };
    };

    # Claude Desktop gibt es für Linux nicht als Paket – stattdessen die
    # Web-Version als eigenes Symbol.
    claude = {
      name = "Claude";
      comment = "claude.ai im Browser öffnen";
      icon = "internet-chat";
      exec = "firefox --new-window https://claude.ai";
      categories = [ "Network" ];
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
