{ outputs, lib, ... }:
{
  programs.ssh = {
    enable = true;

    extraConfig = ''
      #req'd for enabling yubikey-agent
      AddKeysToAgent yes
    '';

    matchBlocks = {
      "yubikey-hosts" = {
        host = "gitlab.com github.com";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_yubikey" # This is an auto symlink to whatever yubikey is plugged in. See hosts/common/optional/yubikey
          "~/.ssh/id_mila"
          "~/.ssh/id_manu" # fallback to id_manu if yubis aren't present
        ];
      };
    };
    # FIXME: This should probably be for git systems only?
    #controlMaster = "auto";
    #controlPath = "~/.ssh/sockets/S.%r@%h:%p";
    #controlPersist = "60m";

    #extraConfig = ''
    #Include config.d/*
    #'';
  };
  #  home.file.".ssh/sockets/.keep".text = "# Managed by Home Manager";
}
