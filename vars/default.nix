{ inputs, ... }:
{
  #TODO refactor to inherit email, domain and fullname
  inherit (inputs.nix-secrets) networking;

  username = "ta";
  domain = inputs.nix-secrets.domain;
  userFullName = inputs.nix-secrets.full-name;
  handle = "emergentmind";
  userEmail = inputs.nix-secrets.email.user;
  gitHubEmail = "7410928+emergentmind@users.noreply.github.com";
  gitLabEmail = "2889621-emergentmind@users.noreply.gitlab.com";
  workEmail = inputs.nix-secrets.email.work;
  backupEmail = inputs.nix-secrets.email.backup;
  notifierEmail = inputs.nix-secrets.email.notifier;
  persistFolder = "/persist";

  # System-specific settings (FIXME: Likely make options)
  isMinimal = false; # Used to indicate nixos-installer build
  isWork = false; # Used to indicate a host that uses work resources
  scaling = "1"; # Used to indicate what scaling to use. Floating point number
}
