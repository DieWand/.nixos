# Verknüpfungen für die App-Übersicht / das Dock – alles per Maus bedienbar.
{ pkgs, ... }:
let
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
in
{
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
