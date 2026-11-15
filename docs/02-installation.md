# 02 – Installation

Gilt für die Erstinstallation und für die Wiederherstellung nach einem Wipe.

> **Die Installation löscht die gesamte Festplatte**, auch ein vorhandenes
> Windows. Persönliche Daten vorher sichern.

## Vorbereitung

| Brauchst du | Wozu |
| --- | --- |
| USB-Stick (≥ 4 GB) mit dem NixOS-ISO „GNOME, 64-bit“ von <https://nixos.org/download> | Installationsmedium |
| Internet (WLAN oder LAN) | Lädt alle Pakete |
| Ein neues Verschlüsselungs-Passwort | Wird bei jedem Start abgefragt; nicht wiederherstellbar |
| Bei Wiederherstellung: den age-Schlüssel aus dem Passwortmanager | Entschlüsselt Secrets und Backup |

Im BIOS/UEFI (bei ASUS: `F2` beim Start): **Secure Boot ausschalten**, Boot-Modus
UEFI. Vom Stick starten (bei ASUS: `Esc` für das Boot-Menü).

## Installation

Im gestarteten Stick WLAN verbinden, Terminal öffnen:

```sh
nix-shell -p git --run "git clone https://github.com/DieWand/.nixos && sudo ./.nixos/install.sh"
```

Liegt der gewünschte Stand nicht auf dem Standard-Branch, hinter `git clone`
ein `-b <branch>` einfügen. Bei einem privaten Repo fragt Git nach Zugangsdaten.

Ablauf des Skripts:

1. Zeigt die Zielfestplatte und verlangt die Eingabe `ja`.
2. Partitioniert und verschlüsselt – fragt nach dem **neuen LUKS-Passwort**.
3. Erzeugt beim ersten Mal `hardware-configuration.nix` für dieses Gerät.
4. Fragt (nur wenn Secrets existieren) nach dem **age-Schlüssel**.
5. Installiert das System. Das dauert, u. a. weil die GNOME-Shell für das
   Theming lokal gebaut wird.
6. Kopiert das Repo nach `/home/nschulze/.nixos`.

Andere Festplatte als in `hosts/amboss/disko.nix` eingetragen:
`sudo ./.nixos/install.sh /dev/sda` (Namen mit `lsblk` nachsehen).

## Nach dem ersten Start

1. LUKS-Passwort eingeben, als `nschulze` mit Passwort `changeme` anmelden.
2. **Sofort** im Terminal `passwd` ausführen.
3. Nur bei der Erstinstallation:
   ```sh
   cd ~/.nixos
   just secrets-init        # zeigt den age-Schlüssel → in den Passwortmanager
   just switch
   git add -A && git commit -m "Hardware, Lock, Secrets" && git push
   ```
   Damit landen `hardware-configuration.nix`, `flake.lock` und die
   verschlüsselten Secrets im Repo. Für `git push` vorher Name/E-Mail in
   `modules/home/git.nix` eintragen und bei GitHub anmelden.
4. Einmalig von Hand: `rustup default stable`; in Firefox, Steam und den
   JetBrains-IDEs anmelden; Flatpaks neu installieren; persönliche Daten aus dem
   Backup zurückspielen ([05](05-daten-und-secrets.md)).

## Manuelle Installation (falls das Skript scheitert)

```sh
git clone https://github.com/DieWand/.nixos && cd .nixos
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount hosts/amboss/disko.nix
sudo nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > hosts/amboss/hardware-configuration.nix
git add -A
sudo nixos-install --no-root-passwd --flake .#amboss
sudo cp -a . /mnt/home/nschulze/.nixos
sudo nixos-enter --root /mnt -c "chown -R nschulze:users /home/nschulze"
```
