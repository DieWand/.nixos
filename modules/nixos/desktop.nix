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
