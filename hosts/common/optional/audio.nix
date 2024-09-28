{ pkgs, ... }:
{
  # sound.enable = true; #deprecated in 24.11 TODO remove this line when 24.11 release
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      playerctl # cli utility and lib for controlling media players
      # pamixer # cli pulseaudio sound mixer
      ;
  };
}
