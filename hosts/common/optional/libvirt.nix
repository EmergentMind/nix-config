{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  virtLib = inputs.nixvirt.lib;
in
{
  imports = [
    inputs.nixvirt.nixosModules.default
  ];
  boot.kernelModules = [ "vfio-pci" ];

  # Enable yubikey direction into a QEMU image https://github.com/NixOS/nixpkgs/issues/39618
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      # HW TPM Emulation (need to check what systems I have already have hw TPM that could be used)
      #swtpm.enable = true;
      ovmf = {
        enable = true;
        # Re-enable if needing to test secure boot inside a VM
        #        packages = [
        #          (pkgs.OVMF.override {
        #            secureBoot = true;
        #            tpmSupport = true;
        #          }).fd
        #        ];
      };
    };
  };
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {

      networks = [
        {
          active = true;
          definition = virtLib.network.writeXML {
            uuid = "8e91d351-e902-4fce-99b6-e5ea88ac9b80";
            name = "vm-lan";
            forward = {
              mode = "nat";
              nat = {
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
                ipv6 = false;
              };
            };
            bridge = {
              name = "virbr0";
              stp = true;
              delay = 0;
            };
            ipv6 = false;
            ip =
              let
                subnet = inputs.nix-secrets.networking.subnets.vm-lan;
              in
              {
                address = subnet.gateway;
                netmask = "255.255.255.0";
                dhcp = {
                  range = {
                    start = "${subnet.triplet}.100";
                    end = "${subnet.triplet}.254";
                  };
                };
                hosts = lib.attrValues subnet.hosts;
              };
          };
        }
      ];
    };
  };

  # Need to add [File (in the menu bar) -> Add connection] when start for the first time
  programs.virt-manager.enable = true;

  environment.systemPackages = [
    # QEMU/KVM(HostCpuOnly), provides:
    #   qemu-storage-daemon qemu-edid qemu-ga
    #   qemu-pr-helper qemu-nbd elf2dmp qemu-img qemu-io
    #   qemu-kvm qemu-system-x86_64 qemu-system-aarch64 qemu-system-i386
    pkgs.qemu_kvm

    # Install QEMU(other architectures), provides:
    #   ......
    #   qemu-loongarch64 qemu-system-loongarch64
    #   qemu-riscv64 qemu-system-riscv64 qemu-riscv32  qemu-system-riscv32
    #   qemu-system-arm qemu-arm qemu-armeb qemu-system-aarch64 qemu-aarch64 qemu-aarch64_be
    #   qemu-system-xtensa qemu-xtensa qemu-system-xtensaeb qemu-xtensaeb
    #   ......
    pkgs.qemu
  ];

  users.users.${config.hostSpec.username} = {
    extraGroups = [ "libvirtd" ];
  };
}
