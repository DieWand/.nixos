#!/usr/bin/env bash
# Sammelt die Hardware-Daten, die für die Konfiguration gebraucht werden.
# Läuft auf jedem Linux (auch vom NixOS-Installationsstick). Ändert nichts.
# Gibt keine Seriennummern aus.
#
#   bash hardware-info.sh > hardware.txt
set -u

section() { printf '\n=== %s ===\n' "$1"; }
have() { command -v "$1" > /dev/null 2>&1; }
dmi() { cat "/sys/class/dmi/id/$1" 2> /dev/null || echo "?"; }

section "Modell"
echo "Hersteller: $(dmi sys_vendor)"
echo "Produkt:    $(dmi product_name)"
echo "Familie:    $(dmi product_family)"
echo "Board:      $(dmi board_name)"
echo "BIOS:       $(dmi bios_version) ($(dmi bios_date))"

section "CPU"
if have lscpu; then lscpu | grep -E '^(Model name|Modellname|CPU\(s\)|Architecture|Architektur)'; else grep -m1 'model name' /proc/cpuinfo; fi

section "Arbeitsspeicher"
grep MemTotal /proc/meminfo

section "Grafikkarten (inkl. Bus-ID)"
if have lspci; then lspci -nn | grep -E 'VGA|3D|Display' || echo "keine gefunden"; else echo "lspci fehlt (nix-shell -p pciutils)"; fi

section "Grafik-Umschaltung (MUX)"
mux=/sys/devices/platform/asus-nb-wmi/gpu_mux_mode
if [ -e "$mux" ]; then echo "MUX vorhanden, Wert: $(cat "$mux" 2> /dev/null) (1 = Hybrid, 0 = Nvidia direkt)"; else echo "kein ASUS-MUX gefunden ($mux fehlt)"; fi
ls /sys/devices/platform/asus-nb-wmi/ 2> /dev/null | grep -E 'dgpu|egpu|mux|throttle|charge' || true

section "Laufwerke"
if have lsblk; then lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,FSTYPE,MOUNTPOINTS; fi

section "Bildschirm / Anschlüsse"
for c in /sys/class/drm/card*-*; do
  [ -e "$c/status" ] || continue
  printf '%s: %s' "$(basename "$c")" "$(cat "$c/status")"
  [ -s "$c/modes" ] && printf ', beste Auflösung %s' "$(head -n1 "$c/modes")"
  echo
done

section "Netzwerk / Bluetooth"
if have lspci; then lspci -nn | grep -iE 'network|ethernet|wireless' || true; fi

section "USB-Geräte (Webcam, Bluetooth, Fingerabdruck)"
if have lsusb; then lsusb | grep -viE 'root hub'; else echo "lsusb fehlt (nix-shell -p usbutils)"; fi

section "Akku"
for b in /sys/class/power_supply/BAT*; do
  [ -d "$b" ] || continue
  echo "$(basename "$b"): $(cat "$b/model_name" 2> /dev/null), Ladegrenze einstellbar: $([ -e "$b/charge_control_end_threshold" ] && echo ja || echo nein)"
done

section "Firmware"
if [ -d /sys/firmware/efi ]; then echo "Boot-Modus: UEFI"; else echo "Boot-Modus: BIOS/Legacy (!)"; fi
if have mokutil; then mokutil --sb-state 2> /dev/null; elif have bootctl; then bootctl status 2> /dev/null | grep -i 'secure boot'; fi

section "Kernel"
uname -r

section "NixOS-Hardware-Konfiguration"
if have nixos-generate-config; then
  nixos-generate-config --no-filesystems --show-hardware-config 2> /dev/null || echo "(mit sudo erneut ausführen)"
else
  echo "nixos-generate-config nicht vorhanden (nur auf dem NixOS-Stick)"
fi
