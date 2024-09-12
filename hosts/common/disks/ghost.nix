# NOTE: ... is needed because dikso passes diskoFile
{

  lib,
  pkgs,
  configVars,
  ...
}:
{
  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/nvme1n1"; #1TB 
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptprimary";
                passwordFile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                settings = {
                  allowDiscards = true;
                  # https://github.com/hmajid2301/dotfiles/blob/a0b511c79b11d9b4afe2a5e2b7eedb2af23e288f/systems/x86_64-linux/framework/disks.nix#L36
                  crypttabExtraOpts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # force overwrite
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@persist" = {
                      mountpoint = "${configVars.persistFolder}";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      }
      extra = {
        type = "disk";
        device = "/dev/nvme0n1"; #250GB 
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptextra";
                passwordfile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                settings = {
                  allowdiscards = true;
                  # https://github.com/hmajid2301/dotfiles/blob/a0b511c79b11d9b4afe2a5e2b7eedb2af23e288f/systems/x86_64-linux/framework/disks.nix#l36
                  crypttabextraopts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                # subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraargs = [ "-f" ]; # force overwrite
                  subvolumes = {
                    "@extra" = {
                      mountpoint = "/mnt/extra";
                      mountoptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      }
      VMS = {
        type = "disk";
        device = "/dev/sda"; #500GB 
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptvms";
                passwordfile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                settings = {
                  allowdiscards = true;
                  # https://github.com/hmajid2301/dotfiles/blob/a0b511c79b11d9b4afe2a5e2b7eedb2af23e288f/systems/x86_64-linux/framework/disks.nix#l36
                  crypttabextraopts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                # subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraargs = [ "-f" ]; # force overwrite
                  subvolumes = {
                    "@vms" = {
                      mountpoint = "/mnt/vms";
                      mountoptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
      # Raid disks are assembled in mdadm below
      RAID1-disk0 = {
        type = "disk";
        device = "/dev/sdb"; #1.8TB 
        content = {
          type = "gpt";
          partitions = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "raid1";
            };
          };
        };
      };
      RAID1-disk1 = {
        type = "disk";
        device = "/dev/sdc"; #1.8TB 
        content = {
          type = "gpt";
          partitions = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "raid1";
            };
          };
        };
      };
    };
    mdadm = {
      raid1 = {
        type = "mdadm";
        level = 1; # Raid 1 (mirroring)
        content = {
          type = "gpt";
          partitions.primary = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptraid1";
            passwordfile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
            settings = {
              allowdiscards = true;
              # https://github.com/hmajid2301/dotfiles/blob/a0b511c79b11d9b4afe2a5e2b7eedb2af23e288f/systems/x86_64-linux/framework/disks.nix#l36
              crypttabextraopts = [
                "fido2-device=auto"
                "token-timeout=10"
              ];
            };
            # subvolumes must set a mountpoint in order to be mounted,
            # unless their parent is mounted
            content = {
              type = "btrfs";
              extraargs = [ "-f" ]; # force overwrite
              subvolumes = {
                "@vms" = {
                  mountpoint = "/mnt/raid";
                  mountoptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
};

environment.systemPackages = [
pkgs.yubikey-manager # For luks fido2 enrollment before full install
];
}
