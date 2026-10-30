{
  config,
  lib,
  ...
}:
{
  shell = {
    # appLauncher = {
    launcher = {
      layout = "full";
      # width = 760;
      search_position = "bottom";
      default_view = "recent";
      categories = true;
      show_settings_button = false;
      show_session_button = false;
      app_grid = false;
      track_usage = true;
      # autoPasteClipboard = false;
      # clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
      # clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
      # clipboardWrapText = true;
      # customLaunchPrefix = "";
      # customLaunchPrefixEnabled = false;
      # density = "default";
      # enableClipPreview = true;
      # enableClipboardChips = true;
      # enableClipboardHistory = true;
      # enableClipboardSmartIcons = true;
      # enableSessionSearch = true;
      # enableSettingsSearch = true;
      # enableWindowsSearch = true;
      # iconMode = "tabler";
      # ignoreMouseInput = false;
      # overviewLayer = true;
      # pinnedApps = [
      # ];
      # position = "center";
      # screenshotAnnotationTool = "";
      # showCategories = true;
      # showIconBackground = true;
      # sortByMostUsed = true;
      # terminalCommand = "ghostty -e";
      # viewMode = "list";
    };
  };
  audio = {
    # mprisBlacklist = [
    # ];
    # preferredPlayer = "spotify";
    # spectrumFrameRate = 30;
    # spectrumMirrored = true;
    # visualizerType = "linear";
    # volumeFeedback = false;
    # volumeFeedbackSoundFile = "";
    # volumeOverdrive = false;
    # volumeStep = 5;
  };
  brightness = {
    # brightnessStep = 5;
    enable_ddcutil = false;
    minimum_brightness = 0.2;
    sync_all_monitors = false;
  };
  calendar = {
    enabled = true;
    event_date_format = "%A %e %B";
    # cards = [
    #   {
    #     enabled = true;
    #     id = "calendar-header-card";
    #   }
    #   {
    #     enabled = true;
    #     id = "calendar-month-card";
    #   }
    #   {
    #     enabled = true;
    #     id = "weather-card";
    #   }
    # ];
  };
  # colorSchemes = {
  #   predefinedScheme = "default";
  #   darkMode = true;
  #   generationMethod = "tonal-spot";
  #   manualSunrise = "06 =30";
  #   manualSunset = "18 =30";
  #   monitorForColors = "";
  #   schedulingMode = "off";
  #   syncGsettings = false;
  #   useWallpaperColors = false;
  # };
  theme = {
    mode = "dark";
    shell_mode = "follow";
  };
  # control_center = {
  #   cards = [
  #     {
  #       enabled = true;
  #       id = "profile-card";
  #     }
  #     {
  #       enabled = true;
  #       id = "shortcuts-card";
  #     }
  #     {
  #       enabled = true;
  #       id = "audio-card";
  #     }
  #     {
  #       enabled = true;
  #       id = "brightness-card";
  #     }
  #     {
  #       enabled = true;
  #       id = "weather-card";
  #     }
  #     {
  #       enabled = false;
  #       id = "media-sysmon-card";
  #     }
  #   ];
  #   diskPath = "/";
  #   position = "center";
  #   shortcuts = {
  #     left = [
  #       {
  #         id = "Network";
  #       }
  #       {
  #         id = "Bluetooth";
  #       }
  #       {
  #         id = "WallpaperSelector";
  #       }
  #       {
  #         id = "NoctaliaPerformance";
  #       }
  #     ];
  #     right = [
  #       {
  #         id = "Notifications";
  #       }
  #       {
  #         id = "PowerProfile";
  #       }
  #     ];
  #   };
  # };
  desktop_widgets = {
    enabled = false;
  };
  general = {
    allowPanelsOnScreenWithoutBar = true;
    allowPasswordWithFprintd = true;
    animationDisabled = false;
    animationSpeed = 1;
    autoStartAuth = false;
    avatarImage = "/home/ta/dev/nix/nix-assets/images/avatars/emergentmind_avatar_200k.png";
    boxRadiusRatio = 1;
    clockFormat = "HH:mm ";
    clockStyle = "custom";
    compactLockScreen = true;
    dimmerOpacity = 0.25;
    enableBlurBehind = true;
    enableLockScreenCountdown = false;
    enableLockScreenMediaControls = false;
    enableShadows = true;
    forceBlackScreenCorners = false;
    iRadiusRatio = 1;
    keybinds = {
      keyDown = [
        "Down"
        "Ctrl+J"
      ];
      keyEnter = [
        "Return"
        "Enter"
      ];
      keyEscape = [
        "Esc"
      ];
      keyLeft = [
        "Left"
        "Ctrl+H"
      ];
      keyRemove = [
        "Del"
      ];
      keyRight = [
        "Right"
        "Ctrl+L"
      ];
      keyUp = [
        "Up"
        "Ctrl+K"
      ];
    };
    language = "";
    lockOnSuspend = true;
    lockScreenAnimations = true;
    lockScreenBlur = 0.25;
    lockScreenCountdownDuration = 4000;
    lockScreenMonitors = [
    ];
    lockScreenTint = 0.6;
    passwordChars = false;
    radiusRatio = 1;
    reverseScroll = false;
    scaleRatio = 1;
    screenRadiusRatio = 1;
    shadowDirection = "bottom_right";
    shadowOffsetX = 2;
    shadowOffsetY = 3;
    showChangelogOnStartup = true;
    showHibernateOnLockScreen = false;
    showScreenCorners = false;
    showSessionButtonsOnLockScreen = false;
    smoothScrollEnabled = true;
    telemetryEnabled = false;
  };
  hooks = {
    colorGeneration = "";
    darkModeChange = "";
    enabled = false;
    performanceModeDisabled = "";
    performanceModeEnabled = "";
    screenLock = "";
    screenUnlock = "";
    session = "";
    startup = "";
    wallpaperChange = "";
  };
  idle = {
    behavior_order = [
      "lock"
      "screen-off"

    ];
    # Seconds to fade a fullscreen surface-tint overlay, then run the idle command.
    # 0 disables the overlay (the command runs as soon as the compositor reports idle).
    # Parsed between 0 and 120; the in-app Settings stepper uses whole seconds 0–30.
    # pre_action_fade_seconds = 4.0;
    behavior = {
      lock = {
        timeout = 660;
        action = "lock";
        enabled = false;
      };
      screen-off = {
        timeout = 600;
        action = "screen_off";
        enabled = false;
      };
      suspend = {
        timeout = 1800;
        action = "lock_and_suspend";
        enabled = false;
      };
    };
  };
  location = {
    auto_locate = false;
    address = "Calgary, AB";
  };
  # network = {
  #   bluetoothAutoConnect = true;
  #   bluetoothDetailsViewMode = "grid";
  #   bluetoothHideUnnamedDevices = false;
  #   bluetoothRssiPollIntervalMs = 60000;
  #   bluetoothRssiPollingEnabled = false;
  #   disableDiscoverability = false;
  #   networkPanelView = "wifi";
  #   wifiDetailsViewMode = "grid";
  # };
  nightlight = {
    enabled = false;
  };
  noctaliaPerformance = {
    disableDesktopWidgets = true;
    disableWallpaper = true;
  };
  plugins = {
    autoUpdate = false;
    notifyUpdates = true;
  };
  sessionMenu = {
    countdownDuration = 1000;
    enableCountdown = false;
    largeButtonsLayout = "single-row";
    largeButtonsStyle = true;
    position = "center";
    powerOptions = [
      {
        action = "lock";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "1";
      }
      {
        action = "suspend";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "2";
      }
      {
        action = "hibernate";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "3";
      }
      {
        action = "reboot";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "4";
      }
      {
        action = "logout";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "5";
      }
      {
        action = "shutdown";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "6";
      }
      {
        action = "rebootToUefi";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "7";
      }
      {
        action = "userspaceReboot";
        command = "";
        countdownEnabled = true;
        enabled = false;
        keybind = "";
      }
    ];
    showHeader = true;
    showKeybinds = true;
  };
  settingsVersion = 59;
  systemMonitor = {
    cpuCriticalThreshold = 90;
    cpuWarningThreshold = 80;
    criticalColor = "";
    diskAvailCriticalThreshold = 10;
    diskAvailWarningThreshold = 20;
    diskCriticalThreshold = 90;
    diskWarningThreshold = 80;
    enableDgpuMonitoring = false;
    externalMonitor = "resources || missioncenter || jdsystemmonitor ||
corestats || system-monitoring-center || gnome-system-monitor ||
plasma-systemmonitor || mate-system-monitor || ukui-system-monitor ||
deepin-system-monitor || pantheon-system-monitor";
    gpuCriticalThreshold = 90;
    gpuWarningThreshold = 80;
    memCriticalThreshold = 90;
    memWarningThreshold = 80;
    swapCriticalThreshold = 90;
    swapWarningThreshold = 80;
    tempCriticalThreshold = 90;
    tempWarningThreshold = 80;
    useCustomColors = false;
    warningColor = "";
  };
  templates = {
    activeTemplates = [
    ];
    enableUserTheming = false;
  };
  wallpaper = {
    enabled = true;
    default.path = "/home/ta/sync/wallpaper/hostCollections/ghost";
    automationEnabled = true;
    enableMultiMonitorDirectories = true;
    favorites = [
    ];
    fillColor = "#000000";
    fillMode = "crop";
    hideWallpaperFilenames = false;
    linkLightAndDarkWallpapers = true;
    monitorDirectories = [
    ];
    overviewBlur = 0.4;
    overviewEnabled = false;
    overviewTint = 0.6;
    panelPosition = "center";
    randomIntervalSec = 3600;
    setWallpaperOnAllMonitors = true;
    showHiddenFiles = false;
    skipStartupTransition = false;
    solidColor = "#1a1a2e";
    sortOrder = "name";
    transitionDuration = 1500;
    transitionEdgeSmoothness = 0.05;
    transitionType = [
      "fade"
      "disc"
      "stripes"
      "wipe"
      "pixelate"
      "honeycomb"
    ];
    useOriginalImages = false;
    useSolidColor = false;
    useWallhaven = false;
    viewMode = "single";
    wallhavenApiKey = "";
    wallhavenCategories = "111";
    wallhavenOrder = "desc";
    wallhavenPurity = "100";
    wallhavenQuery = "";
    wallhavenRatios = "";
    wallhavenResolutionHeight = "";
    wallhavenResolutionMode = "atleast";
    wallhavenResolutionWidth = "";
    wallhavenSorting = "relevance";
    wallpaperChangeMode = "random";
  };
  weather = {
    enabled = true;
    refresh = 15;
    unit = "metric";
    effects = true;
  };
  bar = {
    autoHideDelay = 500;
    autoShowDelay = 150;
    barType = "simple";
    capsuleColorKey = "none";
    contentPadding = 2;
    density = "comfortable";
    displayMode = "always_visible";
    enableExclusionZoneInset = true;
    fontScale = 1.25;
    frameRadius = 12;
    frameThickness = 8;
    hideOnOverview = false;
    marginHorizontal = 4;
    marginVertical = 4;
    middleClickAction = "none";
    middleClickCommand = "";
    middleClickFollowMouse = false;
    mouseWheelAction = "none";
    mouseWheelWrap = true;
    outerCorners = true;
    position = "top";
    reverseScroll = false;
    rightClickAction = "controlCenter";
    rightClickCommand = "";
    rightClickFollowMouse = true;
    screenOverrides = [
    ];
    showCapsule = false;
    showOnWorkspaceSwitch = true;
    showOutline = false;
    useSeparateOpacity = true;
    widgetSpacing = 6;
    widgets = {
      left = [
        {
          id = "Spacer";
          width = 30;
        }
        {
          characterCount = 10;
          colorizeIcons = false;
          emptyColor = "tertiary";
          enableScrollWheel = false;
          focusedColor = "primary";
          followFocusedScreen = false;
          fontWeight = "semibold";
          groupedBorderOpacity = 1;
          hideUnoccupied = false;
          iconScale = 0.8;
          id = "Workspace";
          labelMode = "name";
          occupiedColor = "tertiary";
          pillSize = lib.mkForce 0.85;
          showApplications = false;
          showApplicationsHover = false;
          showBadge = true;
          showLabelsOnlyWhenOccupied = false;
          unfocusedIconsOpacity = 1;
        }
      ];
      center = [
        {
          defaultSettings = {
            activeColor = "primary";
            enableToast = true;
            hideInactive = false;
            iconSpacing = 4;
            inactiveColor = "none";
            micFilterRegex = "";
            removeMargins = false;
          };
          id = "plugin:privacy-indicator";
        }
        {
          colorizeIcons = false;
          hideMode = "hidden";
          id = "ActiveWindow";
          maxWidth = 500;
          scrollingMode = "hover";
          showIcon = true;
          showText = true;
          textColor = "secondary";
          useFixedWidth = false;
        }
        {
          defaultSettings = {
            compactMode = false;
            defaultDuration = 0;
            iconColor = "none";
            textColor = "none";
          };
          id = "plugin:timer";
        }
      ];
      right = [
        {
          hideWhenZero = false;
          hideWhenZeroUnread = false;
          iconColor = "none";
          id = "NotificationHistory";
          showUnreadBadge = true;
          unreadBadgeColor = "error";
        }
        {
          id = "plugin:rss-feed";
        }
        {
          blacklist = [
          ];
          chevronColor = "none";
          colorizeIcons = false;
          drawerEnabled = true;
          hidePassive = false;
          id = "Tray";
          pinned = [
          ];
        }
        {
          displayMode = "alwaysShow";
          iconColor = "none";
          id = "Volume";
          middleClickCommand = "pwvucontrol || pavucontrol";
          textColor = "none";
        }
        {
          displayMode = "onhover";
          iconColor = "none";
          id = "Network";
          textColor = "none";
        }
        {
          displayMode = "onhover";
          iconColor = "none";
          id = "Bluetooth";
          textColor = "none";
        }
        {
          deviceNativePath = "__default__";
          displayMode = "graphic-clean";
          hideIfIdle = false;
          hideIfNotDetected = true;
          id = "Battery";
          showNoctaliaPerformance = false;
          showPowerProfiles = false;
        }
        {
          clockColor = "secondary";
          customFont = "";
          formatHorizontal = "HH:mm  yy.MM.dd.ddd";
          formatVertical = "HH:mm yy.MM.dd";
          id = "Clock";
          tooltipFormat = "HH:mm  yy.MM.dd.ddd";
          useCustomFont = false;
        }
        {
          id = "Spacer";
          width = 30;
        }
      ];
    };
    backgroundOpacity = lib.mkForce 1;
  };
  battery = {
    warning_threshold = 20;
  };
  dock = {
    animationSpeed = 1;
    colorizeIcons = false;
    deadOpacity = 0.6;
    displayMode = "auto_hide";
    dockType = "floating";
    enabled = false;
    floatingRatio = 1;
    groupApps = false;
    groupClickAction = "cycle";
    groupContextMenuMode = "extended";
    groupIndicatorStyle = "dots";
    inactiveIndicators = false;
    indicatorColor = "primary";
    indicatorOpacity = 0.6;
    indicatorThickness = 3;
    launcherIcon = "";
    launcherIconColor = "none";
    launcherPosition = "end";
    launcherUseDistroLogo = false;
    onlySameOutput = true;
    pinnedApps = [
    ];
    pinnedStatic = false;
    position = "bottom";
    showDockIndicator = false;
    showLauncherIcon = false;
    sitOnFrame = false;
    size = 1;
  };
  notifications = {
    enable_daemon = true;
    show_app_name = true;
    show_actions = true;
    position = "top_right";
    layer = "top";
    scale = 1.0;
    # width = 500;
    background_opacitty = 0.95;
    border = true;
    border_color = "outline";
    border_width = 1;
    follow_focused_output = false; # show new toasts on the focused output; keep visible toasts pinned
    offset_x = 20; # absolute horizontal margin from the screen edge
    offset_y = 8; # absolute vertical margin from the screen edge
    monitors = [ ]; # empty = all monitors; otherwise connector/description selectors (e.g. ["eDP-1", "DP-1"])
    collapse_on_dismiss = true; # slide remaining toasts to close gaps when one is dismissed
    keep_dismissed_in_history = true; # keep history entries when their toasts are dismissed
    max_visible = 3; # maximum on-screen toasts; 0 = fill available space (all visible)
    history_retention_hours = 0; # delete stored history older than this; 0 keeps it indefinitely
    filter = {
      chrome = {
        match = "chrome";
        play_sound = false;
        show_toast = false;
      };
      chromium = {
        match = "chromium";
        play_sound = false;
        show_toast = false;
      };
      discord = {
        match = "discord";
        play_sound = false;
        show_toast = false;
      };
      firefox = {
        match = "firefox";
        play_sound = false;
        show_toast = false;
      };
    };
  };
  osd = {
    autoHideMs = 2000;
    enabled = true;
    enabledTypes = [
      0
      1
      2
    ];
    location = "top_right";
    monitors = [
    ];
    overlayLayer = true;
  };
  ui = {
    boxBorderEnabled = false;
    fontDefaultScale = 1;
    fontFixedScale = 1;
    panelsAttachedToBar = true;
    scrollbarAlwaysVisible = true;
    settingsPanelMode = "window";
    settingsPanelSideBarCardStyle = true;
    tooltipsEnabled = true;
    translucentWidgets = true;
    panelBackgroundOpacity = lib.mkForce 0.75;
  };
  dark = {
    mSurface = lib.mkForce "#${config.lib.stylix.colors.base00}";
    mOnSurface = lib.mkForce "#${config.lib.stylix.colors.base03}";
    mSurfaceVariant = lib.mkForce "#${config.lib.stylix.colors.base01}";
    mOnSurfaceVariant = lib.mkForce "#${config.lib.stylix.colors.base04}";

    mPrimary = lib.mkForce "#${config.lib.stylix.colors.base02}";
    mOnPrimary = lib.mkForce "#${config.lib.stylix.colors.base0E}";
    mSecondary = lib.mkForce "#${config.lib.stylix.colors.base0F}";
    mOnSecondary = lib.mkForce "#${config.lib.stylix.colors.base01}";
    mTertiary = lib.mkForce "#${config.lib.stylix.colors.base01}";
    mOnTertiary = lib.mkForce "#${config.lib.stylix.colors.base0F}";
    mHover = lib.mkForce "#${config.lib.stylix.colors.base01}";
    mOnHover = lib.mkForce "#${config.lib.stylix.colors.base0A}";

    mError = lib.mkForce "#${config.lib.stylix.colors.base08}";
    mOnError = lib.mkForce "#${config.lib.stylix.colors.base00}";

    mOutline = lib.mkForce "#${config.lib.stylix.colors.base01}";

    mShadow = lib.mkForce "#000000";
  };
  plugins = {
    auto_update = "all";
  };
  # plugins =
  #   let
  #     url = "https://github.com/noctalia-dev/noctalia-plugins";
  #   in
  #   {
  #     sources = [
  #       {
  #         enabled = true;
  #         name = "Official Noctalia Plugins";
  #         inherit url;
  #       }
  #     ];
  #     states = {
  #       privacy-indicator = {
  #         enabled = true;
  #         sourceUrl = url;
  #       };
  #       rss-feed = {
  #         enabled = true;
  #         sourceUrl = url;
  #       };
  #       timer = {
  #         enabled = true;
  #         sourceUrl = url;
  #       };
  #     };
  #     version = 2;
  #   };
  plugin_settings = {
    #   privacy-indicator = {
    #     activeColor = "error";
    #     enableToast = false;
    #     hideInactive = lib.mkForce true;
    #     iconSpacing = 4;
    #     inactiveColor = "none";
    #     micFilterRegex = "";
    #     removeMargins = false;
    #   };
    #   timer = {
    #     compactMode = false;
    #     defaultDuration = 0;
    #     iconColor = "secondary";
    #     textColor = "secondary";
    #   };
  };
}
