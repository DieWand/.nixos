# Shell: fish (Vorschläge & Syntaxfarben ohne Konfiguration) + starship-Prompt.
{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
    shellAbbrs = {
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      gs = "git status";
    };
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true; # `z ordner` springt in oft benutzte Ordner
  programs.fzf.enable = true; # Strg+R: Verlauf durchsuchen
  programs.bat.enable = true;
  programs.eza.enable = true;

  home.packages = with pkgs; [
    fastfetch
    ripgrep
    fd
    jq
    tree
  ];
}
