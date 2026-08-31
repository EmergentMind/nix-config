#
# clara on grovr
#

{ lib, config, ... }:
{
  isNormalUser = true;
  extraGroups =
    let
      ifTheyExist = groups: lib.filter (group: lib.hasAttr group config.users.groups) groups;
    in
    lib.flatten [
      (ifTheyExist [
        "audio"
        "video"
      ])
    ];
}
