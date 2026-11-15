# Desktop: GNOME auf Wayland, Ton, Schriften, Drucken.
{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Weniger vorinstallierter Ballast.
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-tour
    gnome-music
    gnome-maps
  ];

  # Ton über PipeWire – HDMI-Audio erscheint automatisch als Ausgabegerät.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;

  # Flatpak: Programme per Klick über die App „Software“ installieren
  # (Spotify, Discord, …). Diese Apps stehen NICHT im Repo.
  services.flatpak.enable = true;
  systemd.services.flatpak-flathub = {
    description = "Flathub als Flatpak-Quelle eintragen";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 60;
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    vlc
  ];
}
