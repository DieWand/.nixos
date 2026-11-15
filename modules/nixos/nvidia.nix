# Nvidia-Grafik (Hybrid: integrierte GPU + Nvidia).
# Wichtig für HDMI: bei vielen Gaming-Laptops hängt der HDMI-Ausgang an der
# Nvidia-Karte – ohne diesen Treiber bleibt der Fernseher schwarz.
{ config, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # Offene Kernel-Module: für GTX 16xx / RTX 20xx und neuer.
    # TODO(hardware): bei älterer Karte auf false setzen.
    open = true;
    # Sauberes Aufwachen aus dem Standby.
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # TODO(hardware): Bus-IDs aus `lspci` eintragen, dann schläft die
    # Nvidia-Karte im Akkubetrieb und wird nur bei Bedarf geweckt.
    # powerManagement.finegrained = true;
    # prime = {
    #   offload.enable = true;
    #   offload.enableOffloadCmd = true;
    #   amdgpuBusId = "PCI:6:0:0";
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };
}
