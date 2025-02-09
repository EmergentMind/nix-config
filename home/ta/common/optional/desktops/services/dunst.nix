#
# Dunst
# Notification Daemon
#
{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    inherit (pkgs) libnotify; # required by dunst
  };

  services.dunst = {
    enable = true;
    #    waylandDisplay = ""; # set the service's WAYLAND_DISPLAY environment variable
    #    configFile = "";
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = "16x16";
    };
    settings = {
      global = {
        # Allow a small subset of html markup:<b></b>, <i></i>, <s></s>, and <u></u>.
        # For a complete reference see
        # <http://developer.gnome.org/pango/stable/PangoMarkupFormat.html>.
        # If markup is not allowed, those tags will be stripped out of the message.
        allow_markup = "yes";

        # The format of the message.  Possible variables are:
        #   %a  appname
        #   %s  summary
        #   %b  body
        #   %i  iconname (including its path)
        #   %I  iconname (without its path)
        #   %p  progress value if set ([  0%] to [100%]) or nothing
        # Markup is allowed
        format = "%I %s %p\\n%b";

        #TODO dynamic fonts
        #font = "Droid Sans 12";
        alignment = "left"; # Options are "left", "center", and "right".

        sort = "yes"; # Sort messages by urgency.
        indicate_hidden = "yes"; # Show how many messages are currently hidden (because of geometry).

        # The frequency with which text that is longer than the notification
        # window allows bounces back and forth.
        # This option conflicts with "word_wrap".
        # Set to 0 to disable.
        bounce_freq = 5;

        # Show age of message if message is older than show_age_threshold
        # seconds.
        # Set to -1 to disable.
        show_age_threshold = 60;

        # Split notifications into multiple lines if they don't fit into
        # geometry.
        word_wrap = "no";

        # Ignore newlines '\n' in notifications.
        ignore_newline = "no";

        # The geometry of the window:
        #   [{width}]x{height}[+/-{x}+/-{y}]
        # The geometry of the message window.
        # The height is measured in number of notifications everything else
        # in pixels.  If the width is omitted but the height is given
        # ("-geometry x2"), the message window expands over the whole screen
        # (dmenu-like).  If width is 0, the window expands to the longest
        # message displayed.  A positive x is measured from the left, a
        # negative from the right side of the screen.  Y is measured from
        # the top and down respectevly.
        # The width can be negative.  In this case the actual width is the
        # screen width minus the width defined in within the geometry option.
        geometry = "0x4-25+25";

        # Shrink window if it's smaller than the width.  Will be ignored if
        # width is 0.
        shrink = "yes";

        # Display notification on focused monitor.  Possible modes are:
        #   mouse: follow mouse pointer
        #   keyboard: follow window with keyboard focus
        #   none: don't follow anything
        #
        # "keyboard" needs a windowmanager that exports the _NET_ACTIVE_WINDOW property.
        # This should be the case for almost all modern windowmanagers.
        #
        # If this option is set to mouse or keyboard, the monitor option will be ignored.
        follow = "mouse";

        # Should a notification popped up from history be sticky or timeout
        # as if it would normally do.
        sticky_history = "yes";

        # Maximum amount of notifications kept in history
        history_length = 20;

        # Display indicators for URLs (U) and actions (A).
        show_indicators = "yes";

        # The height of a single line.  If the height is smaller than the
        # font height, it will get raised to the font height.
        # This adds empty space above and under the text.
        line_height = 0;

        # Draw a line of "separator_height" pixel height between two
        # notifications. Set to 0 to disable.
        separator_height = 1;

        # Padding between text and separator.
        padding = 8;

        # Horizontal padding.
        horizontal_padding = 10;

        # The transparency of the window.  Range: [0; 100].
        # This option will only work if a compositing windowmanager is
        # present (e.g. xcompmgr, compiz, etc.).
        transparency = 15;

        # Define a color for the separator.
        # possible values are:
        #  * auto: dunst tries to find a color fitting to the background;
        #  * foreground: use the same color as the foreground;
        #  * frame: use the same color as the frame;
        #  * anything else will be interpreted as a X color.
        # separator_color = "#454947";

        # Print a notification on startup.
        # This is mainly for error detection, since dbus (re-)starts dunst
        # automatically after a crash.

        #set to true for debugging
        startup_notification = false;

        # Align icons left/right/off
        icon_position = "left";

        width = 300;
        height = 300;
        offset = "30x50";
        #origin = "top-right";
        origin = "top-center";

        #TODO dynamic theme colours
        #      frame_color = "#dc7f41";

        # Browser for opening urls in context menu.
        browser = "firefox";
      };

      frame = {
        width = 2;
        #TODO dynamic colours
        #        color = "#dc7f41";
      };

      shortcuts = {
        # Shortcuts are specified as [modifier+][modifier+]...key
        # Available modifiers are "ctrl", "mod1" (the alt-key), "mod2",
        # "mod3" and "mod4" (windows-key).
        # Xev might be helpful to find names for keys.

        # Close notification.
        close = "mod1+space";

        # Close all notifications.
        close_all = "ctrl+mod1+space";

        # Redisplay last message(s).
        history = "ctrl+mod4+h";

        # Context menu.
        context = "ctrl+mod1+c";
      };

      urgency_low = {
        #TODO dynamic colours
        #        background = "#1e1e20";
        #        foreground = "#c5c8c6";
        timeout = 10;
      };

      urgency_normal = {
        #TODO dynamic colours
        #        background = "#1e1e20";
        #        foreground = "#c5c8c6";
        timeout = 10;
      };

      urgency_critical = {
        #TODO dynamic colours
        #        background = "#1e1e20";
        #        foreground = "#c5c8c6";
        timeout = 0;
      };
    };
  };
}
