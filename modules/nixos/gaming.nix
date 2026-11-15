# Spiele: Steam (inkl. Proton für Windows-Spiele).
{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    # Zusätzliche Proton-Version für Spiele, die mit der Standardversion zicken.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Mehr Leistung im Spiel: in Steam als Startoption `gamemoderun %command%`.
  programs.gamemode.enable = true;

  environment.systemPackages = [ pkgs.mangohud ]; # FPS-Anzeige: `mangohud %command%`
}
