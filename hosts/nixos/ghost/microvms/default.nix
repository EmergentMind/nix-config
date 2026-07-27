{
  config,
  lib,
  namespace,
  ...
}:
{
  imports = [
    (lib.custom.microvms.mkMicrovms ./.)
  ];
  ${namespace}.microvms.vmLan = config.hostSpec.networking.subnets.c-lan;
}
