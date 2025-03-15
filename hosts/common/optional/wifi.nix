{ pkgs, ... }:

# FIXME(wifi): Untested, but seems like a useful idea
# https://github.com/ihgann/nixos-config-1/blob/master/hosts/electron/configuration.nix

# FIXME(wifi): Possibly add something like below to remove internal domain stuff when on external wifi
# https://github.com/linyinfeng/dotfiles/blob/main/nixos/profiles/networking/network-manager/default.nix

# FIXME(wifi): Auto connect VPN when on untrusted wifi network:
# https://github.com/Defelo/nixos/blob/main/system/networking.nix
{
  environment.systemPackages = [
    pkgs.networkmanagerapplet
  ];

  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";

      source =
        pkgs.writeText "disable-wireless-when-wired" # sh
          ''
            IFACE=$1
            ACTION=$2
            nmcli=${pkgs.networkmanager}/bin/nmcli

            case ''${IFACE} in
                eth*|en*)
                    case ''${ACTION} in
                        up)
                            logger "disabling wifi radio"
                            $nmcli radio wifi off
                            ;;
                        down)
                            logger "enabling wifi radio"
                            $nmcli radio wifi on
                            ;;
                    esac
                    ;;
            esac
          '';
    }
  ];
}
