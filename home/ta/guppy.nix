{ configVars, ... }:
{
  imports = [
    #################### Required Configs ####################
    common/core #required

    #################### Host-specific Optional Configs ####################

  ];

  services.yubikey-touch-detector.enable = true;

  home = {
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";
  };
}
