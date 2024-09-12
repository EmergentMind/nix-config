{ pkgs, configVars, ... }:
{
  # Must be installed at the system level
  # https://discourse.nixos.org/t/ssl-peer-certificate-or-ssh-remote-key-was-not-ok-when-launching-steam/40274
  programs.steam.enable = true;
  environment.variables = {
    STEAM_FORCE_DESKTOPUI_SCALING = configVars.scaling;
  };
}
