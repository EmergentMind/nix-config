{ pkgs, ... }:
{
  # SANE - scanner access now easy
  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.samsung-unified-linux-driver
      pkgs.hplipWithPlugin
    ];
    #extraBackends = [ pkgs.sane-airscan ]; # For network scanners
  };
  services.udev.packages = [ pkgs.sane-airscan ];
  services.ipp-usb.enable = true;

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      simple-scan # GUI scanning application
      sane-frontends
      ; # Command-line scanning tools
  };

  # If your scanner is networked, you might need to open a port
  # networking.firewall.allowedTCPPorts = [ 9100 ];
}
