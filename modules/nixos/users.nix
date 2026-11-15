# Benutzerkonto.
{ pkgs, ... }:
{
  programs.fish.enable = true;

  users.users.nschulze = {
    isNormalUser = true;
    description = "nschulze";
    shell = pkgs.fish;
    extraGroups = [
      "wheel" # sudo
      "networkmanager"
      "docker"
      "video"
      "audio"
    ];
    # Nur für den ersten Login – danach sofort mit `passwd` ändern!
    initialPassword = "changeme";
  };
}
