{ outputs, lib, ... }:
{
  programs.ssh = {
    enable = true;

    # req'd for enabling yubikey-agent
    extraConfig = ''
      AddKeysToAgent yes
    '';

    matchBlocks = {
      "git" = {
        host = "gitlab.com github.com";
        user = "git";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_yubikey" # This is an auto symlink to whatever yubikey is plugged in. See hosts/common/optional/yubikey
          "~/.ssh/id_manu" # fallback to id_manu if yubis aren't present
        ];
      };
    };
    # FIXME: This should probably be for git systems only?
    # Should create PR for this to be part of MatchBlocks
    controlMaster = "auto";
    controlPath = "~/.ssh/sockets/S.%r@%h:%p";
    controlPersist = "10m";
  };
  home.file.".ssh/sockets/.keep".text = "# Managed by Home Manager";
}
