{ config, ... }:
let
  homeDir = config.home.homeDirectory;
in
{
  # Inspiration:
  # - https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/20
  # - https://github.com/gvolpe/nix-config/blob/6feb7e4f47e74a8e3befd2efb423d9232f522ccd/home/programs/browsers/firefox.nix
  # - https://github.com/lucidph3nx/nixos-config/blob/2e42a40cc8d93c25e01dcbe0dacd8de01f4f0c16/modules/home-manager/firefox/default.nix
  # - https://github.com/Kreyren/nixos-config/blob/bd4765eb802a0371de7291980ce999ccff59d619/nixos/users/kreyren/home/modules/web-browsers/firefox/firefox.nix#L116-L148
  #
  # TODO(firefox):
  # - How to set DDG as default?
  # - Tons of settings above I haven't looked into
  # - Go over existing profiles to add settings
  # - Setup a separate work profile?
  # - Port bookmarks and other profile settings over from existing profile
  programs.firefox = {
    enable = true;

    # Refer to https://mozilla.github.io/policy-templates or `about:policies#documentation` in firefox
    policies = {
      AppAutoUpdate = false; # Disable automatic application update
      BackgroundAppUpdate = false; # Disable automatic application update in the background, when the application is not running.
      DefaultDownloadDirectory = "${config.home.homeDirectory}/downloads";
      DisableBuiltinPDFViewer = false;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = false; # Enable Firefox Sync
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false; # Managed by Proton
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        # Exceptions = ["https://example.com"]
      };
      ExtensionUpdate = false;

      # To copy extensions from an existing profile you can do something like this:
      # cat ~/.mozilla/firefox/fb8sickr.default/extensions.json | jq '.addons[] | [.defaultLocale.name, .id]'
      #
      # To add additional extensions, find it on addons.mozilla.org, find
      # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
      # Then, download the XPI by filling it in to the install_url template, unzip it,
      # run `jq .browser_specific_settings.gecko.id manifest.json` or
      # `jq .applications.gecko.id manifest.json` to get the UUID
      ExtensionSettings =
        (
          let
            extension = shortId: uuid: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "normal_installed";
              };
            };
          in
          builtins.listToAttrs [
            #TODO Add more of these and test. not high priority though since mozilla sync will pull them in too
            # Development
            #(extension "user-agent-switcher" "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}") # failed

            # Privacy / Security
            (extension "noscript" "{73a6fe31-595d-460b-a920-fcc0f8843232}")
            (extension "ublock-origin" "uBlock0@raymondhill.net")
            (extension "ignore-cookies" "jid1-KKzOGWgsW3Ao4Q@jetpack") # failed # Ignore cookie setting pop-ups
            (extension "proton-pass" "78272b6fa58f4a1abaac99321d503a20@proton.me")
            (extension "proton-vpn-firefox-extension" "vpn@proton.ch") # failed
            (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
            (extension "cookie-autodelete" "CookieAutoDelete@kennydo.com")

            # Layout / Themeing
            (extension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
            (extension "darkreader" "addon@darkreader.org")

            # Voice
            (extension "domain-in-title" "{966515fa-4c81-4afe-9879-9bbaf8576390}")
            #(extension "rango" "rango@david-tejada")

            # Misc
            (extension "s3download-statusbar" "{6913849f-c79f-4f3e-83e4-890d91ad6154}")
            (extension "auto-tab-discard" "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}")
            (extension "reddit-enhancement-suite" "jid1-xUfzOsOFlzSOXg@jetpack")
          ]
        )
        // {
          # FIXME(firefox): Check into how this works
          #"*" = {
          #  installation_mode = "blocked";
          #  blocked_install_message = "blocked extension install";
          #};
        };

      #"3rdparty".Extensions = { };

    };

    profiles.main = {
      id = 0;
      name = "EmergentMind";
      isDefault = true;

      # FIXME(firefox): These should probably be in a let .. in block so I can re-use if I setup
      # additional profiles
      # Should check ~/.mozilla/firefox/PROFILE_NAME/prefs.js | user.js
      # from your old profiles too
      settings = {
        "signon.rememberSignons" = false; # Disable built-in password manager
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1; # enable compact mode
        "browser.aboutConfig.showWarning" = false;
        "browser.download.dir" = "${homeDir}/downloads";

        "browser.tabs.firefox-view" = true; # Sync tabs across devices
        "ui.systemUsesDarkTheme" = 1; # force dark theme
        "extensions.pocket.enabled" = false;
      };
      #      containers = {
      #        FCWA = {
      #            name = "FCWA";
      #            color = "blue";
      #            icon = "circle";
      #            id = 1;
      #        };
      #        FenceStore = {
      #            name = "The Fence Store";
      #            color = "red";
      #            icon = "fence";
      #            id = 2;
      #        };
      #
      #      };
      #
      # This just uses the default suggestion from home-manager for now
      userChrome = ''
        /* Hide tab bar in FF Quantum */
        @-moz-document url("chrome://browser/content/browser.xul") {
          #TabsToolbar {
            visibility: collapse !important;
            margin-bottom: 21px !important;
          }

          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
            visibility: collapse !important;
          }
        }
      '';
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
