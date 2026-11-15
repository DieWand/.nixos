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

  # TODO(hardware): bei bestätigtem ASUS-Gerät aktivieren
  # (Lüfterprofile, Tastaturbeleuchtung, Ladegrenze):
  # services.asusd.enable = true;
}
