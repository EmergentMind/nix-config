{
  disko.devices = {
    disk = {
      #FIXME change to proper device or make dynamic like figdetingbits
      vda = {
        type = "disk";
        # FIXME change to proper device or make dynamic like figdetingbits
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };

                  "/persist" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/persist";
                  };

                  "/nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };

                  "/swap" = {
                    mountOptions = [ "noatime" ];
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "8192M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
