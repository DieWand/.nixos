# Git + GitHub-Anmeldung.
{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "nschulze";
      # Platzhalter – durch die echte (oder die GitHub-noreply-)Adresse ersetzen.
      user.email = "nschulze@amboss";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # GitHub-CLI. Einmalig `gh auth login` (Anmeldung im Browser) – danach kann
  # git ohne Passwortabfrage pushen.
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings.git_protocol = "https";
  };
}
