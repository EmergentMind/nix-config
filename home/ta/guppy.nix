{ configVars, ... }:
{
  imports = [
    #################### Required Configs ####################
    common/core #required

  ];

  services.yubikey-touch-detector.enable = true;

  home = {
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";
  };
}
