# Netzwerk: WLAN/LAN über NetworkManager (GUI in GNOME), Firewall an.
{ ... }:
{
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
}
