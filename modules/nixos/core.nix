# Basis: Boot, Nix-Einstellungen, Sprache/Tastatur, Aufräumen.
{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    # Die letzten 10 Stände bleiben im Bootmenü wählbar (Rollback).
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";
  services.xserver.xkb.layout = "de";

  zramSwap.enable = true;

  # Erlaubt fremde, vorkompilierte Programme (z. B. von IDEs nachgeladene Tools).
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git
    just
    vim
    wget
    curl
    htop
    unzip
    pciutils
    usbutils
  ];
}
