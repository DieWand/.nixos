# Benutzer-Ebene (Home Manager): alles, was unter ~ liegt.
{ ... }:
{
  imports = [
    ./gnome.nix
    ./niri.nix
    ./browser.nix
    ./shell.nix
    ./terminal.nix
    ./git.nix
    ./editor.nix
    ./dev.nix
    ./shortcuts.nix
  ];

  home.username = "nschulze";
  home.homeDirectory = "/home/nschulze";

  # Qt-Apps folgen dem GNOME-Stil; Stylix unterstützt das dort (noch) nicht.
  stylix.targets.qt.enable = false;

  # Nicht ändern (siehe system.stateVersion).
  home.stateVersion = "26.05";
}
