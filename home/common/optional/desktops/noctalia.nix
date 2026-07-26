{
  config,
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
  programs.noctalia-shell = {
    enable = true;
    plugins =
      let
        url = "https://github.com/noctalia-dev/noctalia-plugins";
      in
      {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            inherit url;
          }
        ];
        states = {
          privacy-indicator = {
            enabled = true;
            sourceUrl = url;
          };
          rss-feed = {
            enabled = true;
            sourceUrl = url;
          };
          timer = {
            enabled = true;
            sourceUrl = url;
          };
        };
        version = 2;
      };
    pluginSettings = {
      privacy-indicator = {
        activeColor = "error";
        enableToast = false;
        hideInactive = lib.mkForce true;
        iconSpacing = 4;
        inactiveColor = "none";
        micFilterRegex = "";
        removeMargins = false;
      };
      timer = {
        compactMode = false;
        defaultDuration = 0;
        iconColor = "secondary";
        textColor = "secondary";
      };
    };
    settings = {
      appLauncher = {
        autoPasteClipboard = false;
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWrapText = true;
        customLaunchPrefix = "";
        customLaunchPrefixEnabled = false;
        density = "default";
        enableClipPreview = true;
        enableClipboardChips = true;
        enableClipboardHistory = true;
        enableClipboardSmartIcons = true;
        enableSessionSearch = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        iconMode = "tabler";
        ignoreMouseInput = false;
        overviewLayer = true;
        pinnedApps = [
        ];
        position = "center";
        screenshotAnnotationTool = "";
        showCategories = true;
        showIconBackground = true;
        sortByMostUsed = true;
        terminalCommand = "ghostty -e";
        viewMode = "list";
      };
      audio = {
        mprisBlacklist = [
        ];
        preferredPlayer = "spotify";
        spectrumFrameRate = 30;
        spectrumMirrored = true;
        visualizerType = "linear";
        volumeFeedback = false;
        volumeFeedbackSoundFile = "";
        volumeOverdrive = false;
        volumeStep = 5;
      };
      brightness = {
        backlightDeviceMappings = [
        ];
        brightnessStep = 5;
        enableDdcSupport = false;
        enforceMinimum = true;
      };
      calendar = {
        cards = [
          {
            enabled = true;
            id = "calendar-header-card";
          }
          {
            enabled = true;
            id = "calendar-month-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
        ];
      };
      colorSchemes = {
        predefinedScheme = "default";
        darkMode = true;
        generationMethod = "tonal-spot";
        manualSunrise = "06 =30";
        manualSunset = "18 =30";
        monitorForColors = "";
        schedulingMode = "off";
        syncGsettings = false;
        useWallpaperColors = false;
      };
      controlCenter = {
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = true;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = false;
            id = "media-sysmon-card";
          }
        ];
        diskPath = "/";
        position = "center";
        shortcuts = {
          left = [
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "WallpaperSelector";
            }
            {
              id = "NoctaliaPerformance";
            }
          ];
          right = [
            {
              id = "Notifications";
            }
            {
              id = "PowerProfile";
            }
          ];
        };
      };
      desktopWidgets = {
        enabled = false;
        gridSnap = false;
        gridSnapScale = false;
        monitorWidgets = [
        ];
        overviewEnabled = true;
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
        customCommands = "[]";
        enabled = false;
        fadeDuration = 5;
        lockCommand = "";
        lockTimeout = 660;
        resumeLockCommand = "";
        resumeScreenOffCommand = "";
        resumeSuspendCommand = "";
        screenOffCommand = "";
        screenOffTimeout = 600;
        suspendCommand = "";
        suspendTimeout = 1800;
      };
      location = {
        analogClockInCalendar = false;
        autoLocate = false;
        firstDayOfWeek = -1;
        hideWeatherCityName = false;
        hideWeatherTimezone = false;
        name = "Calgary";
        showCalendarEvents = true;
        showCalendarWeather = true;
        showWeekNumberInCalendar = false;
        use12hourFormat = false;
        useFahrenheit = false;
        weatherEnabled = true;
        weatherShowEffects = true;
        weatherTaliaMascotAlways = false;
      };
      network = {
        bluetoothAutoConnect = true;
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        bluetoothRssiPollIntervalMs = 60000;
        bluetoothRssiPollingEnabled = false;
        disableDiscoverability = false;
        networkPanelView = "wifi";
        wifiDetailsViewMode = "grid";
      };
      nightLight = {
        autoSchedule = true;
        dayTemp = "6500";
        enabled = false;
        forced = false;
        manualSunrise = "06 =30";
        manualSunset = "18 =30";
        nightTemp = "4000";
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
        batteryCriticalThreshold = 5;
        batteryWarningThreshold = 20;
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
        automationEnabled = true;
        directory = "/home/ta/sync/wallpaper/hostCollections/ghost";
        enableMultiMonitorDirectories = true;
        enabled = true;
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
        monitors = [
        ];
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
        monitors = [
        ];
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
        clearDismissed = true;
        criticalUrgencyDuration = 15;
        density = "default";
        enableBatteryToast = true;
        enableKeyboardLayoutToast = true;
        enableMarkdown = false;
        enableMediaToast = false;
        enabled = true;
        location = "top_right";
        lowUrgencyDuration = 3;
        monitors = [
        ];
        normalUrgencyDuration = 8;
        overlayLayer = true;
        respectExpireTimeout = false;
        saveToHistory = {
          critical = true;
          low = true;
          normal = true;
        };
        sounds = {
          criticalSoundFile = "";
          enabled = false;
          excludedApps = "discord,firefox,chrome,chromium,edge";
          lowSoundFile = "";
          normalSoundFile = "";
          separateSounds = false;
          volume = 0.5;
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
    };
    colors = {
      Surface = lib.mkForce "#${config.lib.stylix.colors.base00}";
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
  };
}
