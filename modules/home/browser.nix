# Firefox, inkl. DRM (Widevine) für Netflix & Co.
{ ... }:
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "media.eme.enabled" = true;
        # Hardware-Videodekodierung
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };

  stylix.targets.firefox.profileNames = [ "default" ];
}
