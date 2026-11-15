# `just` ohne Argumente zeigt diese Liste.
default:
    @just --list

# Änderungen aus dem Repo anwenden
switch:
    sudo nixos-rebuild switch --flake .#amboss

# Neuesten Stand aus Git holen und anwenden
sync:
    git pull --ff-only
    sudo nixos-rebuild switch --flake .#amboss

# Änderungen testen, ohne sie ins Bootmenü zu übernehmen (Neustart = alter Stand)
test:
    sudo nixos-rebuild test --flake .#amboss

# Alles aktualisieren (Pakete, Treiber, Kernel) und anwenden
update:
    nix flake update
    sudo nixos-rebuild switch --flake .#amboss

# Zum vorherigen Stand zurück
rollback:
    sudo nixos-rebuild switch --rollback

# Alte Stände löschen und Speicher freigeben
clean:
    sudo nix-collect-garbage --delete-older-than 14d
    sudo nixos-rebuild boot --flake .#amboss

# Konfiguration prüfen, ohne etwas zu ändern
check:
    nix flake check

# Nix-Dateien formatieren
fmt:
    nix fmt
