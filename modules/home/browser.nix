# Firefox, inkl. DRM (Widevine) für Netflix & Co.
#
# Add-ons werden über Firefox-Richtlinien fest installiert: Nach einer
# Neuinstallation sind sie sofort da und aktualisieren sich selbst von
# addons.mozilla.org. Entfernen lassen sie sich nur hier im Repo.
#
# Weiteres Add-on: Seite auf addons.mozilla.org öffnen, den Namen aus der
# Adresse nehmen (…/addon/<name>/) und unten eintragen. Die Kennung (ID) steht
# nach der ersten Installation unter about:support → „Erweiterungen“.
{ ... }:
let
  addon = slug: extra: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "force_installed";
  } // extra;
in
{
  programs.firefox = {
    enable = true;

    policies = {
      ExtensionSettings = {
        # Passwortmanager – Symbol direkt in der Symbolleiste.
        "jetpack-extension@dashlane.com" = addon "dashlane" {
          default_area = "navbar";
          private_browsing = true;
        };
        # Werbe- und Trackerblocker.
        "uBlock0@raymondhill.net" = addon "ublock-origin" {
          private_browsing = true;
        };
      };

      # Passwörter verwaltet Dashlane – Firefox soll nicht zusätzlich fragen.
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      AutofillCreditCardEnabled = false;

      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
    };

    profiles.default = {
      isDefault = true;
      settings = {
        "media.eme.enabled" = true;
        # Eigene Titelleiste mit Schließen-Knopf – auch unter niri.
        "browser.tabs.inTitlebar" = 1;
        # Hardware-Videodekodierung
        "media.ffmpeg.vaapi.enabled" = true;
        # Add-ons ohne Rückfrage aktivieren.
        "extensions.autoDisableScopes" = 0;
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = [ "default" ];
    # Firefox sieht aus wie eine GNOME-App.
    firefoxGnomeTheme.enable = true;
  };
}
