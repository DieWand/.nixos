# Nvidia RTX 3070 Mobile + integrierte Radeon 680M (Hybrid mit MUX).
# Der HDMI-Ausgang hängt an der Nvidia-Karte – ohne diesen Treiber (oder im
# Grafikmodus „Integrated“) bleibt der Fernseher schwarz.
{ config, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # Offene Kernel-Module (für RTX 20xx und neuer empfohlen).
    open = true;
    # Sauberes Aufwachen aus dem Standby.
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Hybrid-Betrieb: Die Radeon treibt den Bildschirm, die Nvidia-Karte
    # schläft und wird nur bei Bedarf geweckt (Spiele, HDMI).
    # Einzelnes Programm gezielt auf Nvidia starten: `nvidia-offload <programm>`
    powerManagement.finegrained = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
