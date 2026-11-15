# Partitionierung: EFI-Partition + LUKS-verschlüsseltes btrfs.
# Das LUKS-Passwort wird bei der Installation interaktiv abgefragt.
{
  disko.devices.disk.main = {
    type = "disk";
    # TODO(hardware): mit `lsblk` prüfen und anpassen.
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes =
                let
                  opts = [
                    "compress=zstd"
                    "noatime"
                  ];
                in
                {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = opts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = opts;
                  };
                  # Ablage der /home-Snapshots (snapper).
                  "@home-snapshots" = {
                    mountpoint = "/home/.snapshots";
                    mountOptions = opts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = opts;
                  };
                };
            };
          };
        };
      };
    };
  };
}
