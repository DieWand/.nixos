# Firefox, inkl. DRM (Widevine) für Netflix & Co.
{ ... }:
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "media.eme.enabled" = true;
        # Eigene Titelleiste mit Schließen-Knopf – auch unter niri.
        "browser.tabs.inTitlebar" = 1;
        # Hardware-Videodekodierung
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = [ "default" ];
    # Firefox sieht aus wie eine GNOME-App.
    firefoxGnomeTheme.enable = true;
  };
}
