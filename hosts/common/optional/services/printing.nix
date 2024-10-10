# Reminder that CUPS cpanel defaults to localhost:631

{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.samsung-unified-linux-driver ];
    #logging = "debug";
  };

  # Mitigate cups and avahi security issue as described here: https://discourse.nixos.org/t/cups-cups-filters-and-libppd-security-issues/52780/2
  # Note: this will eventually be achievable with the option `services.printing.browsed.enabled = false` but the PR hasn't been merged to unstable as of 09.10.24
  systemd.services.cups-browsed = {
    enable = false;
    unitConfig.Mask = true;
  };

  #FIXME(printing) didn't get this working. can get these values from CUPS but
  #  hardware.printers = {
  #    ensurePrinters = [
  #      {
  #        name = "Samsung_C460_Series";
  #        location = "LocalPrinter";
  #        deviceUri = "usb://Samsung/C460%20Series?serial=ZEW1BJDF50005MT&interface=1";
  #        model = "samsung-unified-linux-driver";
  #      }
  #    ];
  #  };
}
