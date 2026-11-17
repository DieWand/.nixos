# 07 – Hardware

## Dieses Gerät

| | |
| --- | --- |
| Modell | ASUS TUF Gaming A17 **FA707RR** (BIOS 314) |
| CPU | AMD Ryzen 7 6800H (8 Kerne / 16 Threads) |
| Grafik | Radeon 680M (intern, `PCI:5:0:0`) + Nvidia RTX 3070 Mobile (`PCI:1:0:0`), MUX vorhanden |
| RAM | 16 GB |
| Platte | Samsung 1 TB NVMe (`/dev/nvme0n1`), einzige Platte |
| Bildschirm | 1920×1080, intern an der Radeon; **HDMI hängt an der Nvidia-Karte** |
| WLAN / Bluetooth | MediaTek MT7921 (Treiber im Kernel) |
| LAN | Realtek RTL8111/8168 |
| Akku | Ladegrenze einstellbar |
| Fingerabdruck | nicht vorhanden |
| Firmware | UEFI, Secure Boot aus |

Erfasst mit `scripts/hardware-info.sh`. Alle Werte sind in die Konfiguration
eingetragen.

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

## Offene Punkte

| Wo | Punkt |
| --- | --- |
| `modules/home/git.nix` | Echte E-Mail für Commits (aktuell Platzhalter) |
| `hosts/amboss/default.nix` | Backup-Ziel ([05](05-daten-und-secrets.md)) |
| `wallpapers/` | Wallpaper ablegen ([04](04-anpassen.md)) |
