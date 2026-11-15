{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      # TODO: Name und E-Mail für Commits eintragen.
      # user.name = "…";
      # user.email = "…";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
