{
  config,
  osConfig,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.waybar = {
    enable = lib.mkForce false;
  };
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings =
      let
        baseSettings = import ./settings.nix { inherit config lib inputs; };
        hostConfigPath = lib.custom.relativeToRoot "hosts/nixos/${osConfig.hostSpec.hostName}/noctalia.nix";
        hostSettings = if lib.pathExists hostConfigPath then import hostConfigPath else { };
      in
      lib.recursiveUpdate baseSettings hostSettings
      # nixfmt hack
      |> lib.mapAttrs (n: v: lib.mkForce v);
  };
}
