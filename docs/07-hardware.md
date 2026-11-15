# 07 – Hardware

## Annahmen bisher

ASUS TUF Gaming A17 (unbestätigt): AMD-CPU mit integrierter Grafik, Nvidia-Karte
mit MUX-Switch, NVMe-SSD unter `/dev/nvme0n1`, UEFI.

## Welche Daten gebraucht werden

| Angabe | Wofür | Betrifft |
| --- | --- | --- |
| Genaues Modell (z. B. FA707NV) | Passendes `nixos-hardware`-Profil, bekannte Eigenheiten | `hosts/amboss/default.nix` |
| CPU | Microcode, interne Grafik (AMD oder Intel) | `hardware-configuration.nix`, `nvidia.nix` |
| Nvidia-Modell | Offener oder proprietärer Treiber (`open`) | `nvidia.nix` |
| Bus-IDs beider Grafikkarten | Nvidia schläft im Akkubetrieb (`prime`) | `nvidia.nix` |
| MUX vorhanden? | Ob der dritte Grafikmodus existiert | `laptop.nix` |
| Laufwerke: Name, Größe, Anzahl | Ziel der Installation, zweite SSD nutzen? | `disko.nix` |
| WLAN-/Bluetooth-Chip | Ob zusätzliche Firmware nötig ist | `laptop.nix` |
| Bildschirm: Auflösung, Hz | Skalierung, Schriftgrößen | `theme.nix`, `gnome.nix` |
| Fingerabdrucksensor? | Anmelden per Finger | – |
| Ladegrenze einstellbar? | Akkuschonung | `laptop.nix` |
| Boot-Modus, Secure Boot | Muss UEFI sein, Secure Boot aus | – |
| RAM | Größe des zram-Swap | `core.nix` |

Dazu zwei Entscheidungen: Soll ein vorhandenes **Windows** erhalten bleiben
(die Installation löscht sonst alles)? Gibt es eine **zweite SSD**, und wofür?

## Daten sammeln

Vom NixOS-Stick (oder jedem anderen Linux) – ändert nichts am Gerät:

```sh
nix-shell -p git --run "git clone https://github.com/DieWand/.nixos"
sudo bash .nixos/scripts/hardware-info.sh > hardware.txt
```

Den Inhalt von `hardware.txt` weitergeben. Die Datei enthält keine Seriennummern.

Unter Windows genügen fürs Erste: *Einstellungen → System → Info* (Modell, CPU,
RAM), Geräte-Manager → *Grafikkarten* und *Laufwerke*, und das Typenschild auf
der Unterseite (Modell, z. B. „FA707NV“).

## Offene Punkte im Code

Mit `TODO(hardware)` markiert (`grep -rn "TODO" .`):

| Datei | Punkt |
| --- | --- |
| `hosts/amboss/default.nix` | `nixos-hardware`-Modul für das genaue Modell |
| `hosts/amboss/disko.nix` | Festplattenname |
| `hosts/amboss/hardware-configuration.nix` | Platzhalter; wird bei der Installation erzeugt |
| `modules/nixos/nvidia.nix` | `open` je nach Kartengeneration; Bus-IDs für PRIME |
| `modules/home/git.nix` | Name und E-Mail für Commits |

Unabhängig von der Hardware offen: Backup-Ziel ([05](05-daten-und-secrets.md)),
Design ([04](04-anpassen.md)).
