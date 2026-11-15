# Laptop-spezifisch: Energie, Bluetooth, Firmware.
{ ... }:
{
  # Energieprofile (Sparen/Ausgewogen/Leistung) im GNOME-Schnellmenü.
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Firmware-/BIOS-Updates: `fwupdmgr update`
  services.fwupd.enable = true;

  # SSD-Pflege
  services.fstrim.enable = true;

  # ASUS-Dienste: Lüfterprofile, Tastaturbeleuchtung, Ladegrenze (asusd)
  # und Grafik-Umschaltung inkl. MUX-Switch (supergfxd).
  # Modi: Integrated (nur AMD, sparsam) | Hybrid (Standard) | AsusMuxDgpu
  # (Bildschirm direkt an Nvidia, beste Leistung). Umschalten per
  # GNOME-Schnellmenü oder `supergfxctl -m <Modus>`; MUX braucht einen Neustart.
  services.asusd.enable = true;
  services.supergfxd.enable = true;
}
