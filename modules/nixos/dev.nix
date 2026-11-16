# Entwicklung (systemweit): Docker. Dazu der Schalter für die JetBrains-IDEs
# (ausgewertet in modules/home/editor.nix).
{ lib, ... }:
{
  options.amboss.jetbrains.enable = lib.mkEnableOption "JetBrains-IDEs (IDEA, CLion, WebStorm, RustRover)";

  config.virtualisation.docker = {
    enable = true;
    # Alte Images/Container wöchentlich aufräumen.
    autoPrune.enable = true;
  };
}
