# 06 – Fehlerbehebung

## Installation oder Update bricht mit „cannot download“ ab

Ein großer Download ist abgerissen – meist eine JetBrains-IDE. Einfach erneut
starten; bereits Geladenes bleibt erhalten. Bei der Installation: siehe
[02 – Installation](02-installation.md). Hält es an: in
`hosts/amboss/default.nix` `amboss.jetbrains.enable = false;` setzen und die
IDEs später nachholen.

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

## niri: Leiste und Dock fehlen / Bildschirm bleibt leer

Die Shell ist nicht gestartet. `Super+T` öffnet ein Terminal, dort `dms run`
für die Fehlermeldung. Notausgang: `Super+Shift+E` meldet ab; am
Anmeldebildschirm über das Zahnrad GNOME wählen.

## niri: `Super+K` zeigt nichts

`Super+F1` zeigt niris eingebaute, einfachere Übersicht – sie funktioniert
auch, wenn die Shell hängt.

## niri: Shell sieht verstellt aus

`amboss-shell-reset`, dann ab- und anmelden.

## Fernseher bleibt schwarz

1. Grafikmodus prüfen – nicht *Integrated* (Dock: *Grafikmodus*).
2. *Einstellungen → Bildschirme*: wird der Fernseher erkannt?
3. Kabel/Eingang am Fernseher prüfen, einmal ab- und anstecken.

## Kein Ton am Fernseher

Schnellmenü oben rechts → Pfeil am Lautstärkeregler → HDMI-Ausgang wählen.

## „System aktualisieren“ bricht bei Git ab

**„Repo nicht erreichbar“:** Internet prüfen, erneut versuchen.

**„Lokale Änderungen widersprechen dem Stand im Repo“:** Auf dem Laptop und im
Repo wurde dieselbe Stelle unterschiedlich geändert. Es wurde nichts
angewendet. Nachsehen:

```sh
cd ~/.nixos
git log --oneline -3        # der oberste Eintrag sind deine lokalen Änderungen
git show HEAD               # was genau
```

Lokale Änderung verwerfen und den Repo-Stand nehmen:
`git reset --hard origin/main`, danach erneut aktualisieren.

**„Hochladen fehlgeschlagen“:** Einmalig `gh auth login` ausführen. Das System
ist trotzdem aktuell; hochgeladen wird beim nächsten Aktualisieren.

**„Author identity unknown“:** Name/E-Mail fehlen – stehen in
`modules/home/git.nix`. Vor dem ersten `switch` behelfsweise:
`git config user.name nschulze && git config user.email nschulze@amboss`.

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
sparen*. Ob die Nvidia-Karte schläft:
`cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status` (`suspended` = schläft).

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
