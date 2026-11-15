# 06 – Fehlerbehebung

## System startet nach einem Update nicht richtig

Beim Start erscheint das Bootmenü (falls nicht: Leertaste gedrückt halten).
Einen älteren Eintrag wählen. Läuft das System wieder: `just rollback`, damit
der funktionierende Stand Standard wird.

## Schwarzer Bildschirm / kein Anmeldebildschirm

Meist der Nvidia-Treiber nach einem Update. Älteren Eintrag im Bootmenü wählen.
Textkonsole zum Nachsehen: `Strg+Alt+F3`, anmelden, `journalctl -b -p err`.

## Desktop sieht nach einem Update kaputt aus / Effekte fehlen

Eine GNOME-Erweiterung verträgt die neue Version nicht. App *Erweiterungen*
öffnen und die betroffene ausschalten, oder in `modules/home/gnome.nix`
auskommentieren und `just switch`.

## Beim Start nur ein Logo, keine Meldungen

Gewollt (Boot-Animation). `Esc` blendet die Textmeldungen ein.

## Fernseher bleibt schwarz

1. Grafikmodus prüfen – nicht *Integrated* (Dock: *Grafikmodus*).
2. *Einstellungen → Bildschirme*: wird der Fernseher erkannt?
3. Kabel/Eingang am Fernseher prüfen, einmal ab- und anstecken.

## Kein Ton am Fernseher

Schnellmenü oben rechts → Pfeil am Lautstärkeregler → HDMI-Ausgang wählen.

## „System aktualisieren“ bricht bei Git ab

Es gibt lokale Änderungen, die mit dem Stand im Repo kollidieren.

```sh
cd ~/.nixos
git status                 # was ist geändert?
git stash                  # lokale Änderungen beiseitelegen
just sync
git stash pop              # zurückholen (ggf. Konflikte lösen)
```

Häufigster Fall: `flake.lock` nach einem Software-Update nicht committet.

## Build meldet „path … does not exist“ / Datei wird nicht gefunden

Neue Datei noch nicht bei Git angemeldet: `git add -A`, dann erneut.

## Build meldet eine unbekannte oder umbenannte Option

Passiert nach einem Versionssprung. Die Meldung nennt meist den neuen Namen.
Bis zur Korrektur läuft der alte Stand weiter – ein fehlgeschlagener Build
ändert nichts am System.

## Platte voll

```sh
just clean                 # alte Systemstände löschen
docker system prune -a     # Docker-Reste
df -h / /home
```

Auch Snapshots belegen Platz: `snapper -c home list`, löschen mit
`snapper -c home delete <nr>`.

## Grafikmodus lässt sich nicht umschalten

```sh
supergfxctl -g             # aktueller Modus
supergfxctl -s             # unterstützte Modi
systemctl status supergfxd
```

Fehlt *AsusMuxDgpu* in der Liste, hat das Gerät keinen (unterstützten) MUX.

## Akku hält kurz

Grafikmodus *Integrated* wählen, Energiemodus im Schnellmenü auf *Energie
sparen*. Solange die Nvidia-Bus-IDs nicht eingetragen sind
([07](07-hardware.md)), schläft die Nvidia-Karte im Hybrid-Modus möglicherweise nicht.

## „Software“-App zeigt keine Programme

Flathub wurde noch nicht eingetragen (kein Internet beim Start):
`sudo systemctl restart flatpak-flathub`.

## Secrets werden nicht entschlüsselt / Backup startet nicht

Der age-Schlüssel fehlt: `sudo ls -l /var/lib/sops-nix/key.txt`. Schlüssel aus
dem Passwortmanager dort ablegen (root, 600), `just switch`.
Backup-Protokoll: `journalctl -u restic-backups-home -e`.

## Spiel startet nicht

Rechtsklick → *Eigenschaften → Kompatibilität* → andere Proton-Version
(GE-Proton). Status des Spiels auf <https://www.protondb.com> prüfen.

## Passwort vergessen

- **Benutzerpasswort:** älteren Eintrag booten hilft nicht. Vom NixOS-Stick
  starten, Platte entsperren und einhängen, `sudo nixos-enter`, `passwd nschulze`.
- **LUKS-Passwort:** nicht wiederherstellbar. Neuinstallation und Daten aus dem
  Backup.

## Nützliche Befehle

```sh
nixos-rebuild list-generations     # vorhandene Systemstände
journalctl -b -p err               # Fehler seit dem Start
systemctl --failed                 # fehlgeschlagene Dienste
nvidia-smi                         # Zustand der Nvidia-Karte
```
