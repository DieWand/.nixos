# Entwicklung (systemweit): Docker.
{ ... }:
{
  virtualisation.docker = {
    enable = true;
    # Alte Images/Container wöchentlich aufräumen.
    autoPrune.enable = true;
  };
}
