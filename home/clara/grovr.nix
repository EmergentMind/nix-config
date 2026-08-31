{ lib, ... }:
{
  imports = (
    map lib.custom.relativeToRoot (
      # ========== Required modules ==========
      [
        "home/common/core"
        "home/clara/common/"
      ]
      # ========== Optional modules ==========
      ++ (map (f: "home/common/optional/${f}") [
        "desktops/gnome"
      ])
    )
  );

  home.packages = lib.attrValues {

  };

  # additional settings for media user
  programs.firefox = {
    policies = {
      DisableFirefoxAccounts = lib.mkForce true;
    };
    profiles.default = {
      userChrome = "";
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Bookmarks Toolbar";
            toolbar = true;
            bookmarks = [
              {
                name = "Jellyfin";
                url = "http://localhost:8096";
              }
              {
                name = "Netflix";
                url = "https://www.netflix.com";
              }
              {
                name = "Crave";
                url = "https://www.crave.ca";
              }
              {
                name = "Prime";
                url = "https://www.primevideo.com";
              }
              {
                name = "YouTube";
                url = "https://www.youtube.com";
              }
            ];
          }
        ];
      };
    };
  };

  # Keep firefox running if it's closed
  systemd.user.services.firefox = {
    Unit = {
      description = "Firefox Browser";
      After = [
        "graphical-session.target"
        "graphical-session-pre.target"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "simple";
      ExecStart = "/home/clara/.nix-profile/bin/firefox";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
