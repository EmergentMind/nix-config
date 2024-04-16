{ inputs, lib }:
{
  username = "ta";
  domain = inputs.nix-secrets.domain;
  userFullName = inputs.nix-secrets.full-name;
  handle = "emergentmind";
  userEmail = inputs.nix-secrets.user-email;
  gitEmail = "7410928+emergentmind@users.noreply.github.com";
  workEmail = inputs.nix-secrets.work-email;
  networking = import ./networking.nix { inherit lib; };
}
