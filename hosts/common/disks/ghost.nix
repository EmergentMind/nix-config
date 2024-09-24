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
        device = "/dev/nvme0n1"; # 1TB
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
      };
      extra = {
        type = "disk";
        device = "/dev/nvme1n1"; # 250GB
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptextra";
                passwordFile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                settings = {
                  allowDiscards = true;
                  # https://github.com/hmajid2301/dotfiles/blob/a0b511c79b11d9b4afe2a5e2b7eedb2af23e288f/systems/x86_64-linux/framework/disks.nix#l36
                  crypttabExtraOpts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                # Whether to add a boot.initrd.luks.devices entry for the this disk.
                # We only want to unlock cryptroot interactively.
                # You must have a /etc/crypttab entry set up to auto unlock the drive using a key on cryptroot (see /hosts/ghost/default.nix)
                initrdUnlock = if configVars.isMinimal then true else false;

                # subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # force overwrite
                  subvolumes = {
                    "@extra" = {
                      mountpoint = "/mnt/extra";
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
      };
      vms = {
        type = "disk";
        device = "/dev/sda"; # 500GB
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptvms";
                passwordFile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                # Whether to add a boot.initrd.luks.devices entry for the this disk.
                # We only want to unlock cryptroot interactively.
                # You must have a /etc/crypttab entry set up to auto unlock the drive using a key on cryptroot (see /hosts/ghost/default.nix)
                initrdUnlock = if configVars.isMinimal then true else false;

                settings = {
                  allowDiscards = true;
                  # https://github.com/hmajid2301/dotfiles/blob/a0b511c79b11d9b4afe2a5e2b7eedb2af23e288f/systems/x86_64-linux/framework/disks.nix#l36
                  crypttabExtraOpts = [
                    "fido2-device=auto"
                    "token-timeout=10"
                  ];
                };
                # subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # force overwrite
                  subvolumes = {
                    "@vms" = {
                      mountpoint = "/mnt/vms";
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
      };
    };
  };

  environment.systemPackages = [
    pkgs.yubikey-manager # For luks fido2 enrollment before full install
  ];
}
