# Shell: fish (Vorschläge & Syntaxfarben ohne Konfiguration) + starship-Prompt.
#
# Moderne Ersatzwerkzeuge liegen HINTER den gewohnten Befehlen – man tippt
# weiter ls, cd, cat, grep und bekommt die bessere Variante:
#   ls   → eza   (Farben, Symbole, Git-Status)
#   cd   → zoxide (kennt oft benutzte Ordner: `cd proj` springt hin, `cdi` wählt aus)
#   cat  → bat   (Syntaxfarben)
#   grep → ripgrep (schneller, durchsucht Ordner von selbst)
#   top  → btop, du → dust, df → duf
# Das Original erreicht man jederzeit mit `command <befehl>`, z. B. `command grep`.
# Gilt nur beim Tippen im Terminal – Skripte benutzen weiter die Originale.
{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      # Systeminfo beim Öffnen eines Terminalfensters (nicht in IDE-Terminals).
      if test "$TERM" = xterm-ghostty; and test "$SHLVL" = 1
        fastfetch
      end
    '';
    shellAliases = {
      cat = "bat --paging=never --style=plain";
      grep = "rg";
      top = "btop";
      du = "dust";
      df = "duf";
      tree = "eza --tree";
    };
    shellAbbrs = {
      gs = "git status";
      lg = "lazygit";
    };
  };

  programs.starship.enable = true;
  programs.fzf.enable = true; # Strg+R: Verlauf durchsuchen, Strg+T: Datei suchen

  # ls → eza (legt ls, ll, la, lt selbst als Aliase an)
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [ "--group-directories-first" ];
  };

  # cd → zoxide
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true; # `fd name` statt `find . -name "*name*"`

  # Terminal-Programme mit Oberfläche (alle im Farbschema)
  programs.btop.enable = true; # Systemmonitor
  programs.lazygit.enable = true; # Git per Tasten/Maus – Kürzel: lg
  programs.yazi = {
    enable = true; # Dateimanager im Terminal – starten mit: y
    shellWrapperName = "y";
  };

  # Lesbare Git-Diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Kurzhilfe mit Beispielen: `tldr tar`
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  home.packages = with pkgs; [
    fastfetch
    dust
    duf
    jq
  ];
}
