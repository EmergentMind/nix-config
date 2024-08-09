# TODO Not sure I like that this. A second scanPaths call that get's pulled in
# from default.nix in the parent directory. Could be trouble when debugging
# down the road. Noted in long term roadmap.
{
  input,
  outputs,
  configLib,
  ...
}:
{
  imports = (configLib.scanPaths ./.);
}
