{ lib, vmSpecs, ... }:
{
  home-manager = {
    users.${vmSpecs.user} = {
      imports = (
        map lib.custom.relativeToRoot [
          "microvms/home/common/optional/agents.nix"
        ]
      );
    };
  };
}
