# home level sops. see hosts/common/optional/sops.nix for hosts level
# TODO should I split secrtets.yaml into a home level and a hosts level or move to a single sops.nix entirely?

{ inputs, config, ... }:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/secrets.yaml";
  homeDirectory = config.home.homeDirectory;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # This is the ta/dev key and needs to have been copied to this location on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    secrets = {
      "private_keys/maya" = {
        path = "${homeDirectory}/.ssh/id_maya";
      };
      "private_keys/mara" = {
        path = "${homeDirectory}/.ssh/id_mara";
      };
      "private_keys/manu" = {
        path = "${homeDirectory}/.ssh/id_manu";
      };
      "private_keys/mila" = {
        path = "${homeDirectory}/.ssh/id_mila";
      };
      "private_keys/meek" = {
        path = "${homeDirectory}/.ssh/id_meek";
      };
    };
  };
}
