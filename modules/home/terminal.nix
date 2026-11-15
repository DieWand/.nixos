# Terminal: Ghostty (Farben/Schrift kommen von Stylix).
{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      window-padding-x = 10;
      window-padding-y = 10;
      confirm-close-surface = false;
    };
  };
}
