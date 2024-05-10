# home level sops. see hosts/common/optional/sops.nix for hosts level
# TODO should I split secrets.yaml into a home level and a hosts level or move to a single sops.nix entirely?

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
    # This is the location of the host specific age-key for ta and will to have been extracted to this location via hosts/common/core/sops.nix on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    secrets = {
      "ssh_keys/maya" = {
        path = "${homeDirectory}/.ssh/id_maya";
      };
      "ssh_keys/mara" = {
        path = "${homeDirectory}/.ssh/id_mara";
      };
      "ssh_keys/manu" = {
        path = "${homeDirectory}/.ssh/id_manu";
      };
      "ssh_keys/mila" = {
        path = "${homeDirectory}/.ssh/id_mila";
      };
      "ssh_keys/meek" = {
        path = "${homeDirectory}/.ssh/id_meek";
      };
    };
  };
}
