{
  lib,
  inputs,
  osConfig,
  ...
}:
{
  introdus.neovim = {
    enable = true;
    fontSize = 14;
    wrapper = "emergentvim";
  };
  # My custom neovim wrapper, built on top of the introdus neovim base, is enabled by the above
  # and exposed in the config as wrappers.neovim.
  wrappers.neovim = {
    settings =
      if osConfig.hostSpec.isIntrodusDev then
        {
          # Set impure paths to allow hot reloading of `plugin/`, `snippets/`, etc
          unwrappedConfig = "/home/ta/dev/nix/neovim";
          baseConfig = lib.mkForce "/home/ta/dev/nix/introdus/ta/wrappers/neovim";
        }
      else
        {
          hotReload = false;
          # Non-development boxes just use whatever is already in git
          baseConfig = lib.mkForce "${inputs.introdus-git}/wrappers/neovim";
        };
  };
}
