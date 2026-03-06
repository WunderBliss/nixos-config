{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:

{
  imports = [
    # NixVim home-manager module
    inputs.nixvim.homeManagerModules.nixvim

    # DankMaterialShell home-manager module
    inputs.dms.homeModules.dank-material-shell

    # ⚠ VERIFY: Does DMS expose a homeModules.hyprland?
    # If not, remove this line and handle Hyprland startup/keybinds manually.
    # The niri equivalent was: inputs.dms.homeModules.niri
    # inputs.dms.homeModules.hyprland

    inputs.walker.homeManagerModules.default
    # Modular config files
    ./nixvim.nix
  ];

  home = {
    username = "owen";
    homeDirectory = "/home/owen";
    stateVersion = "24.11";

    # ── Extra Packages ────────────────────────────────────────────────
    packages = [
      # Star Citizen via nix-citizen (LUG recommended for NixOS)
      inputs.nix-citizen.packages.${system}.rsi-launcher # Recommended package
      #inputs.nix-citizen.packages.${system}.lug-helper     # LUG Helper tool
      inputs.claude-code.packages.${system}.default
    ];
  };

  # Walker / Elephant
  programs.walker = {
    enable = true;
    runAsService = true;
  };

  # ── DankMaterialShell ─────────────────────────────────────────────────
  # DMS handles ALL theming via matugen + dank16.  It auto-generates:
  #   • GTK 3/4 css (dank-colors.css)  • Qt themes
  #   • Terminal palettes (ghostty, kitty, alacritty, foot, wezterm)
  #   • Editor themes (vscode/vscodium)  • Zen/Firefox userChrome.css
  # Colors are derived from your wallpaper on every wallpaper change.
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true; # ← matugen wallpaper-based theming
    enableAudioWavelength = true;
    enableClipboardPaste = true;
    dgop.package = inputs.dgop.packages.${system}.default;

    settings = {
      currentThemeName = "dynamic";
      currentThemeCategory = "dynamic";
      customThemeFile = "";
      registryThemeVariants = { };
      matugenScheme = "scheme-tonal-spot";
      runUserMatugenTemplates = true;
      matugenTargetMonitor = "";
      popupTransparency = 1;
      dockTransparency = 1;
      widgetBackgroundColor = "sch";
      widgetColorMode = "default";
      controlCenterTileColorMode = "primary";
      buttonColorMode = "primary";
      cornerRadius = 12;
      niriLayoutGapsOverride = -1;
      niriLayoutRadiusOverride = -1;
      niriLayoutBorderSize = -1;
      hyprlandLayoutGapsOverride = -1;
      hyprlandLayoutRadiusOverride = -1;
      hyprlandLayoutBorderSize = -1;
      mangoLayoutGapsOverride = -1;
      mangoLayoutRadiusOverride = -1;
      mangoLayoutBorderSize = -1;
      use24HourClock = true;
      showSeconds = false;
      padHours12Hour = false;
      useFahrenheit = false;
      windSpeedUnit = "kmh";
      nightModeEnabled = false;
      animationSpeed = 1;
      customAnimationDuration = 500;
      syncComponentAnimationSpeeds = true;
      popoutAnimationSpeed = 1;
      popoutCustomAnimationDuration = 150;
      modalAnimationSpeed = 1;
      modalCustomAnimationDuration = 150;
      enableRippleEffects = true;
      wallpaperFillMode = "Fill";
      blurredWallpaperLayer = false;
      blurWallpaperOnOverview = false;
      showLauncherButton = true;
      showWorkspaceSwitcher = true;
      showFocusedWindow = true;
      showWeather = true;
      showMusic = true;
      showClipboard = true;
      showCpuUsage = true;
      showMemUsage = true;
      showCpuTemp = true;
      showGpuTemp = true;
      selectedGpuIndex = 0;
      enabledGpuPciIds = [ ];
      showSystemTray = true;
      showClock = true;
      showNotificationButton = true;
      showBattery = true;
      showControlCenterButton = true;
      showCapsLockIndicator = true;
      controlCenterShowNetworkIcon = true;
      controlCenterShowBluetoothIcon = true;
      controlCenterShowAudioIcon = true;
      controlCenterShowAudioPercent = false;
      controlCenterShowVpnIcon = true;
      controlCenterShowBrightnessIcon = false;
      controlCenterShowBrightnessPercent = false;
      controlCenterShowMicIcon = false;
      controlCenterShowMicPercent = false;
      controlCenterShowBatteryIcon = false;
      controlCenterShowPrinterIcon = false;
      controlCenterShowScreenSharingIcon = true;
      showPrivacyButton = true;
      privacyShowMicIcon = false;
      privacyShowCameraIcon = false;
      privacyShowScreenShareIcon = false;
      controlCenterWidgets = [
        {
          id = "volumeSlider";
          enabled = true;
          width = 50;
        }
        {
          id = "brightnessSlider";
          enabled = true;
          width = 50;
        }
        {
          id = "wifi";
          enabled = true;
          width = 50;
        }
        {
          id = "bluetooth";
          enabled = true;
          width = 50;
        }
        {
          id = "audioOutput";
          enabled = true;
          width = 50;
        }
        {
          id = "audioInput";
          enabled = true;
          width = 50;
        }
        {
          id = "nightMode";
          enabled = true;
          width = 50;
        }
        {
          id = "darkMode";
          enabled = true;
          width = 50;
        }
      ];
      showWorkspaceIndex = false;
      showWorkspaceName = false;
      showWorkspacePadding = false;
      workspaceScrolling = false;
      showWorkspaceApps = false;
      workspaceDragReorder = true;
      maxWorkspaceIcons = 3;
      workspaceAppIconSizeOffset = 0;
      groupWorkspaceApps = true;
      workspaceFollowFocus = false;
      showOccupiedWorkspacesOnly = false;
      reverseScrolling = false;
      dwlShowAllTags = false;
      workspaceColorMode = "default";
      workspaceOccupiedColorMode = "none";
      workspaceUnfocusedColorMode = "default";
      workspaceUrgentColorMode = "default";
      workspaceFocusedBorderEnabled = false;
      workspaceFocusedBorderColor = "primary";
      workspaceFocusedBorderThickness = 2;
      workspaceNameIcons = { };
      waveProgressEnabled = true;
      scrollTitleEnabled = true;
      audioVisualizerEnabled = true;
      audioScrollMode = "volume";
      audioWheelScrollAmount = 5;
      clockCompactMode = false;
      focusedWindowCompactMode = false;
      runningAppsCompactMode = true;
      barMaxVisibleApps = 0;
      barMaxVisibleRunningApps = 0;
      barShowOverflowBadge = true;
      appsDockHideIndicators = false;
      appsDockColorizeActive = false;
      appsDockActiveColorMode = "primary";
      appsDockEnlargeOnHover = false;
      appsDockEnlargePercentage = 125;
      appsDockIconSizePercentage = 100;
      keyboardLayoutNameCompactMode = false;
      runningAppsCurrentWorkspace = true;
      runningAppsGroupByApp = false;
      runningAppsCurrentMonitor = false;
      appIdSubstitutions = [
        {
          pattern = "Spotify";
          replacement = "spotify";
          type = "exact";
        }
        {
          pattern = "beepertexts";
          replacement = "beeper";
          type = "exact";
        }
        {
          pattern = "home assistant desktop";
          replacement = "homeassistant-desktop";
          type = "exact";
        }
        {
          pattern = "com.transmissionbt.transmission";
          replacement = "transmission-gtk";
          type = "contains";
        }
        {
          pattern = "^steam_app_(\\d+)$";
          replacement = "steam_icon_$1";
          type = "regex";
        }
      ];
      centeringMode = "index";
      clockDateFormat = "";
      lockDateFormat = "";
      mediaSize = 1;
      appLauncherViewMode = "list";
      spotlightModalViewMode = "list";
      browserPickerViewMode = "grid";
      browserUsageHistory = {
        "zen-beta" = {
          count = 2;
          lastUsed = 1772782988240;
          name = "Zen Browser (Beta)";
        };
      };
      appPickerViewMode = "grid";
      filePickerUsageHistory = { };
      sortAppsAlphabetically = false;
      appLauncherGridColumns = 4;
      spotlightCloseNiriOverview = true;
      spotlightSectionViewModes = { };
      appDrawerSectionViewModes = { };
      niriOverviewOverlayEnabled = true;
      dankLauncherV2Size = "compact";
      dankLauncherV2BorderEnabled = false;
      dankLauncherV2BorderThickness = 2;
      dankLauncherV2BorderColor = "primary";
      dankLauncherV2ShowFooter = true;
      dankLauncherV2UnloadOnClose = false;
      useAutoLocation = false;
      weatherEnabled = true;
      networkPreference = "auto";
      iconTheme = "System Default";
      cursorSettings = {
        theme = "System Default";
        size = 24;
        niri = {
          hideWhenTyping = false;
          hideAfterInactiveMs = 0;
        };
        hyprland = {
          hideOnKeyPress = false;
          hideOnTouch = false;
          inactiveTimeout = 0;
        };
        dwl = {
          cursorHideTimeout = 0;
        };
      };
      launcherLogoMode = "apps";
      launcherLogoCustomPath = "";
      launcherLogoColorOverride = "";
      launcherLogoColorInvertOnMode = false;
      launcherLogoBrightness = 0.5;
      launcherLogoContrast = 1;
      launcherLogoSizeOffset = 0;
      fontFamily = "Inter Variable";
      monoFontFamily = "Fira Code";
      fontWeight = 400;
      fontScale = 1;
      notepadUseMonospace = true;
      notepadFontFamily = "";
      notepadFontSize = 14;
      notepadShowLineNumbers = false;
      notepadTransparencyOverride = -1;
      notepadLastCustomTransparency = 0.7;
      soundsEnabled = true;
      useSystemSoundTheme = false;
      soundNewNotification = true;
      soundVolumeChanged = true;
      soundPluggedIn = true;
      acMonitorTimeout = 0;
      acLockTimeout = 0;
      acSuspendTimeout = 0;
      acSuspendBehavior = 0;
      acProfileName = "";
      batteryMonitorTimeout = 0;
      batteryLockTimeout = 0;
      batterySuspendTimeout = 0;
      batterySuspendBehavior = 0;
      batteryProfileName = "";
      batteryChargeLimit = 100;
      lockBeforeSuspend = false;
      loginctlLockIntegration = true;
      fadeToLockEnabled = true;
      fadeToLockGracePeriod = 5;
      fadeToDpmsEnabled = true;
      fadeToDpmsGracePeriod = 5;
      launchPrefix = "";
      brightnessDevicePins = { };
      wifiNetworkPins = { };
      bluetoothDevicePins = { };
      audioInputDevicePins = { };
      audioOutputDevicePins = { };
      gtkThemingEnabled = false;
      qtThemingEnabled = false;
      syncModeWithPortal = true;
      terminalsAlwaysDark = false;
      runDmsMatugenTemplates = true;
      matugenTemplateGtk = true;
      matugenTemplateNiri = false;
      matugenTemplateHyprland = true;
      matugenTemplateMangowc = false;
      matugenTemplateQt5ct = false;
      matugenTemplateQt6ct = false;
      matugenTemplateFirefox = false;
      matugenTemplatePywalfox = false;
      matugenTemplateZenBrowser = true;
      matugenTemplateVesktop = true;
      matugenTemplateEquibop = false;
      matugenTemplateGhostty = true;
      matugenTemplateKitty = false;
      matugenTemplateFoot = false;
      matugenTemplateAlacritty = false;
      matugenTemplateNeovim = true;
      matugenTemplateWezterm = false;
      matugenTemplateDgop = true;
      matugenTemplateKcolorscheme = true;
      matugenTemplateVscode = false;
      matugenTemplateEmacs = false;
      showDock = false;
      dockAutoHide = true;
      dockSmartAutoHide = false;
      dockGroupByApp = false;
      dockOpenOnOverview = false;
      dockPosition = 1;
      dockSpacing = 4;
      dockBottomGap = 0;
      dockMargin = 0;
      dockIconSize = 40;
      dockIndicatorStyle = "circle";
      dockBorderEnabled = true;
      dockBorderColor = "surfaceText";
      dockBorderOpacity = 1;
      dockBorderThickness = 1;
      dockIsolateDisplays = false;
      dockLauncherEnabled = true;
      dockLauncherLogoMode = "compositor";
      dockLauncherLogoCustomPath = "";
      dockLauncherLogoColorOverride = "";
      dockLauncherLogoSizeOffset = 0;
      dockLauncherLogoBrightness = 0.5;
      dockLauncherLogoContrast = 1;
      dockMaxVisibleApps = 0;
      dockMaxVisibleRunningApps = 0;
      dockShowOverflowBadge = true;
      notificationOverlayEnabled = false;
      notificationPopupShadowEnabled = true;
      notificationPopupPrivacyMode = false;
      modalDarkenBackground = true;
      lockScreenShowPowerActions = true;
      lockScreenShowSystemIcons = true;
      lockScreenShowTime = true;
      lockScreenShowDate = true;
      lockScreenShowProfileImage = true;
      lockScreenShowPasswordField = true;
      lockScreenShowMediaPlayer = true;
      lockScreenPowerOffMonitorsOnLock = false;
      lockAtStartup = false;
      enableFprint = false;
      maxFprintTries = 15;
      lockScreenActiveMonitor = "all";
      lockScreenInactiveColor = "#000000";
      lockScreenNotificationMode = 0;
      hideBrightnessSlider = false;
      notificationTimeoutLow = 5000;
      notificationTimeoutNormal = 5000;
      notificationTimeoutCritical = 0;
      notificationCompactMode = false;
      notificationPopupPosition = 0;
      notificationAnimationSpeed = 1;
      notificationCustomAnimationDuration = 400;
      notificationHistoryEnabled = true;
      notificationHistoryMaxCount = 50;
      notificationHistoryMaxAgeDays = 7;
      notificationHistorySaveLow = true;
      notificationHistorySaveNormal = true;
      notificationHistorySaveCritical = true;
      notificationRules = [ ];
      osdAlwaysShowValue = false;
      osdPosition = 5;
      osdVolumeEnabled = true;
      osdMediaVolumeEnabled = true;
      osdMediaPlaybackEnabled = false;
      osdBrightnessEnabled = true;
      osdIdleInhibitorEnabled = true;
      osdMicMuteEnabled = true;
      osdCapsLockEnabled = true;
      osdPowerProfileEnabled = false;
      osdAudioOutputEnabled = true;
      powerActionConfirm = true;
      powerActionHoldDuration = 0.5;
      powerMenuActions = [
        "reboot"
        "logout"
        "poweroff"
        "lock"
        "suspend"
        "restart"
      ];
      powerMenuDefaultAction = "logout";
      powerMenuGridLayout = false;
      customPowerActionLock = "";
      customPowerActionLogout = "";
      customPowerActionSuspend = "";
      customPowerActionHibernate = "";
      customPowerActionReboot = "";
      customPowerActionPowerOff = "";
      updaterHideWidget = false;
      updaterUseCustomCommand = false;
      updaterCustomCommand = "";
      updaterTerminalAdditionalParams = "";
      displayNameMode = "system";
      screenPreferences = { };
      showOnLastDisplay = { };
      niriOutputSettings = { };
      hyprlandOutputSettings = {
        "DP-1" = {
          bitdepth = 10;
        };
      };
      displayProfiles = { };
      activeDisplayProfile = { };
      displayProfileAutoSelect = false;
      displayShowDisconnected = false;
      displaySnapToEdge = true;
      barConfigs = [
        {
          id = "default";
          name = "Main Bar";
          enabled = true;
          position = 2;
          screenPreferences = [ "all" ];
          showOnLastDisplay = true;
          leftWidgets = [
            "launcherButton"
            "workspaceSwitcher"
            "focusedWindow"
            {
              id = "idleInhibitor";
              enabled = true;
            }
          ];
          centerWidgets = [
            "music"
            {
              id = "clock";
              enabled = true;
              clockCompactMode = false;
            }
            "weather"
          ];
          rightWidgets = [
            "systemTray"
            "clipboard"
            "cpuUsage"
            "memUsage"
            "notificationButton"
            "controlCenterButton"
          ];
          spacing = 4;
          innerPadding = 4;
          bottomGap = 0;
          transparency = 1;
          widgetTransparency = 1;
          squareCorners = false;
          noBackground = true;
          gothCornersEnabled = false;
          gothCornerRadiusOverride = false;
          gothCornerRadiusValue = 12;
          borderEnabled = false;
          borderColor = "surfaceText";
          borderOpacity = 1;
          borderThickness = 1;
          fontScale = 1;
          autoHide = true;
          autoHideDelay = 250;
          openOnOverview = false;
          visible = true;
          popupGapsAuto = true;
          popupGapsManual = 4;
          maximizeWidgetIcons = false;
          maximizeWidgetText = true;
          removeWidgetPadding = false;
          shadowIntensity = 0;
          widgetOutlineEnabled = false;
          widgetOutlineColor = "primary";
        }
      ];
      desktopClockEnabled = false;
      desktopClockStyle = "analog";
      desktopClockTransparency = 0.8;
      desktopClockColorMode = "primary";
      desktopClockCustomColor = {
        r = 1;
        g = 1;
        b = 1;
        a = 1;
        hsvHue = -1;
        hsvSaturation = 0;
        hsvValue = 1;
        hslHue = -1;
        hslSaturation = 0;
        hslLightness = 1;
        valid = true;
      };
      desktopClockShowDate = true;
      desktopClockShowAnalogNumbers = false;
      desktopClockShowAnalogSeconds = true;
      desktopClockX = -1;
      desktopClockY = -1;
      desktopClockWidth = 280;
      desktopClockHeight = 180;
      desktopClockDisplayPreferences = [ "all" ];
      systemMonitorEnabled = false;
      systemMonitorShowHeader = true;
      systemMonitorTransparency = 0.8;
      systemMonitorColorMode = "primary";
      systemMonitorCustomColor = {
        r = 1;
        g = 1;
        b = 1;
        a = 1;
        hsvHue = -1;
        hsvSaturation = 0;
        hsvValue = 1;
        hslHue = -1;
        hslSaturation = 0;
        hslLightness = 1;
        valid = true;
      };
      systemMonitorShowCpu = true;
      systemMonitorShowCpuGraph = true;
      systemMonitorShowCpuTemp = true;
      systemMonitorShowGpuTemp = false;
      systemMonitorGpuPciId = "";
      systemMonitorShowMemory = true;
      systemMonitorShowMemoryGraph = true;
      systemMonitorShowNetwork = true;
      systemMonitorShowNetworkGraph = true;
      systemMonitorShowDisk = true;
      systemMonitorShowTopProcesses = false;
      systemMonitorTopProcessCount = 3;
      systemMonitorTopProcessSortBy = "cpu";
      systemMonitorGraphInterval = 60;
      systemMonitorLayoutMode = "auto";
      systemMonitorX = -1;
      systemMonitorY = -1;
      systemMonitorWidth = 320;
      systemMonitorHeight = 480;
      systemMonitorDisplayPreferences = [ "all" ];
      systemMonitorVariants = [ ];
      desktopWidgetPositions = { };
      desktopWidgetGridSettings = { };
      desktopWidgetInstances = [ ];
      desktopWidgetGroups = [ ];
      builtInPluginSettings = {
        dms_settings_search = {
          trigger = "?";
        };
      };
      clipboardEnterToPaste = false;
      launcherPluginVisibility = { };
      launcherPluginOrder = [ ];
      configVersion = 5;
    };
  };

  # -- Hypridle --
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # -- Hyprlock --
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 7;
          brightness = 0.6;
        }
      ];
      label = [
        {
          monitor = "";
          text = "$TIME";
          font-size = 72;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgba(255, 255, 255, 0.9)";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "300, 50";
          outline_thickness = 2;
          outer_color = "rgba(0, 0, 0, 0.5)";
          inner_color = "rgba(255, 255, 255, 0.8)";
          font-color = "rgba(255, 255, 255, 0.9)";
          placeholder_text = "Password";
          position = "0, -50";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # ── Hyprland Configuration ────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    # ── Plugins ───────────────────────────────────────────────────────
    # Option A: If hyprlandPlugins.hyprspace is in your nixpkgs:
    #   plugins = [ pkgs.hyprlandPlugins.hyprspace ];
    # Option B: From flake input (remove if Option A works):
    # plugins = [
    #  inputs.hyprspace.packages.${system}.Hyprspace
    #];

    settings = {

      monitorv2 = [
        {
          output = "DP-1";
          mode = "5120x1440@144";
          position = "0x0";
          scale = 1;
          bitdepth = 10;
          cm = "hdr";
          sdrbrightness = 1.5;
          sdrsaturation = 1.5;
          vrr = 1;
          supports_hdr = 10;
        }
      ];

      # ── General ─────────────────────────────────────────────────────
      general = {
        gaps_in = 2; # niri gaps=8 → split between inner/outer
        gaps_out = 0;
        border_size = 1;
        layout = "scrolling";
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "0xffffffff";
        resize_on_border = false;
      };

      scrolling = {
        fullscreen_on_one_column = false;
        follow_min_visible = 0.4;
        explicit_column_widths = "0.25, 0.333, 0.5, 0.666, 1.0";
      };

      # ── Input ───────────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        follow_mouse = 1; # focus-follows-mouse (like niri)
        scroll_factor = 1.0;

        touchpad = {
          tap-to-click = true;
          natural_scroll = true;
        };
      };

      # ── Decoration ──────────────────────────────────────────────────
      decoration = {
        rounding = 0;
        shadow = {
          enabled = true; # niri had shadow.enable = true
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        inactive_opacity = 0.8;
        dim_inactive = true;
        dim_strength = 0.2;
      };

      # ── Animations ──────────────────────────────────────────────────
      animations = {
        enabled = true;
        bezier = "ease, 0.25, 0.1, 0.25, 1";
        animation = [
          "windows, 1, 4, ease"
          "windowsOut, 1, 4, ease, popin 80%"
          "border, 1, 4, ease"
          "fade, 1, 4, ease"
          "workspaces, 1, 3, ease"
        ];
      };

      # ── Misc ────────────────────────────────────────────────────────
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      # ── Hyprspace (Overview Plugin) ─────────────────────────────────
      # ⚠ VERIFY: config keys may vary by hyprspace version — check
      #   https://github.com/KZDKM/Hyprspace for current options.
      plugin = {
        overview = {
          # Show all workspaces in the overview
          showNewWorkspace = true;
          showEmptyWorkspace = true;

          # Drag windows between workspaces in overview
          dragAlpha = 0.8;

          # Gap between workspace thumbnails
          gapsIn = 8;
          gapsOut = 16;

          # Exit overview on workspace switch
          exitOnSwitch = true;
          exitOnClick = true;
        };
      };

      # ── Window Rules ────────────────────────────────────────────────
      windowrule = [
        # Polkit / audio popups float (was niri: authentication-agent-1|pwvucontrol)
        "match:class = ^(authentication-agent-1)$, float on"
        "match:class = ^(pwvucontrol)$, float on"

        # Steam floats
        "match:class = ^(steam)$, float on"

        # Yazi file picker (spawned by xdg-desktop-portal-termfilechooser)
        "match:class = ^(yazi-picker)$, float on, move 300 200"
      ];

      # ── Startup ─────────────────────────────────────────────────────
      # xwayland-satellite removed — Hyprland has native XWayland
      exec-once = [
        # If DMS auto-start (enableSpawn) doesn't work, launch it here:
        # "dank-material-shell"
        "elephant"
        "walker --gapplication-service"
      ];

      # ── Keybindings ─────────────────────────────────────────────────
      "$mod" = "SUPER";

      bind = [
        # ── App Launchers ──────────────────────────────────────────
        "$mod, Return, exec, ghostty"
        "$mod, E, exec, ghostty --class=yazi -e yazi"
        "$mod, B, exec, zen-beta"
        "$mod, SPACE, exec, walker"

        # ── Window Management ──────────────────────────────────────
        "$mod, Q, killactive"
        "$mod SHIFT, E, exit"

        # ── Focus (vim keys — same as your niri setup) ─────────────
        "$mod, H, layoutmsg, focus l"
        "$mod, L, layoutmsg, focus r"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, left, layoutmsg, focus l"
        "$mod, right, layoutmsg, focus r"
        "$mod, down, movefocus, d"
        "$mod, up, movefocus, u"

        # ── Move Windows ───────────────────────────────────────────
        "$mod SHIFT, H, layoutmsg, swapcol l"
        "$mod SHIFT, L, layoutmsg, swapcol r"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, u"

        # ── Sizing ─────────────────────────────────────────────────
        "$mod, R, layoutmsg, colresize +conf"
        "$mod, F, layoutmsg, colresize 1.0"
        "$mod, period, layoutmsg, promote"
        "$mod SHIFT, F, fullscreen, 1" # Maximize (keep bar)
        "$mod CTRL SHIFT, F, fullscreen, 0" # True fullscreen

        # ── Workspaces ─────────────────────────────────────────────
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # ── Move Window to Workspace ───────────────────────────────
        "$mod CTRL, 1, movetoworkspace, 1"
        "$mod CTRL, 2, movetoworkspace, 2"
        "$mod CTRL, 3, movetoworkspace, 3"
        "$mod CTRL, 4, movetoworkspace, 4"
        "$mod CTRL, 5, movetoworkspace, 5"
        "$mod CTRL, 6, movetoworkspace, 6"
        "$mod CTRL, 7, movetoworkspace, 7"
        "$mod CTRL, 8, movetoworkspace, 8"
        "$mod CTRL, 9, movetoworkspace, 9"

        # ── Screenshots (grimblast replaces niri built-in) ─────────
        "$mod, S, exec, grimblast --notify copysave area ~/Pictures/Screenshots/$(date +'Screenshot from %Y-%m-%d %H-%M-%S').png"
        "CTRL, Print, exec, grimblast --notify copysave output ~/Pictures/Screenshots/$(date +'Screenshot from %Y-%m-%d %H-%M-%S').png"
        "ALT, Print, exec, grimblast --notify copysave active ~/Pictures/Screenshots/$(date +'Screenshot from %Y-%m-%d %H-%M-%S').png"

        # ── Floating Toggle ────────────────────────────────────────
        "$mod, V, togglefloating"

        # ── Overview (Hyprspace plugin) ───────────────────────────────
        #"$mod, O, overview:toggle"

        # ── Scroller-Specific Binds ────────────────────────────────
        # These replace niri's consume/expel.  In scroller layout,
        # you can absorb a window into the current column or push
        # it out.
        # ⚠ VERIFY: exact dispatcher names depend on your version.
        # "$mod, comma, scroller:absorb"
        # "$mod, period, scroller:expel"
      ];

      # ── Mouse Bindings ──────────────────────────────────────────────
      bindm = [
        "$mod, mouse:272, movewindow" # Super + LMB to drag
        "$mod, mouse:273, resizewindow" # Super + RMB to resize
      ];
    };
  };

  # ── Ghostty Terminal ──────────────────────────────────────────────────
  # DMS generates ~/.config/ghostty/themes/dankcolors automatically.
  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 13
    theme = dankcolors
    window-decoration = false
    gtk-titlebar = false
    confirm-close-surface = false
    app-notifications = no-clipboard-copy,no-config-reload
  '';

  # ── GTK Theming (DMS-managed via matugen) ─────────────────────────────
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # ── Cursor ────────────────────────────────────────────────────────────
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # ── dconf (dark preference for GTK/portal apps) ──────────────────────
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # ── Fish Shell ────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    shellAliases = {
      v = "nvim";
      lg = "lazygit";
      rebuild = "sudo nixos-rebuild switch --flake .#nixos";
      update = "nix flake update";
      y = "yazi";
    };
    interactiveShellInit = ''
      # Suppress fish greeting
      set -g fish_greeting
      fastfetch
    '';
  };

  # ── Starship Prompt (Tokyo Night preset) ──────────────────────────────
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = lib.concatStrings [
        "[░▒▓](#a3aed2)"
        "[  ](bg:#a3aed2 fg:#090c0c)"
        "[](bg:#769ff0 fg:#a3aed2)"
        "$directory"
        "[](fg:#769ff0 bg:#394260)"
        "$git_branch"
        "$git_status"
        "[](fg:#394260 bg:#212736)"
        "$nodejs"
        "$rust"
        "$golang"
        "$php"
        "$nix_shell"
        "[](fg:#212736 bg:#1d2230)"
        "$time"
        "[ ](fg:#1d2230)"
        "\n$character"
      ];

      directory = {
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = " ";
          Pictures = " ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };

      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      nix_shell = {
        symbol = " ";
        style = "bg:#212736";
        format = "[[ $symbol ($state) ](fg:#769ff0 bg:#212736)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#1d2230";
        format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
      };
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Owen"; # Change to your name
    userEmail = "owen@example.com"; # Change to your email
  };

  # ── Yazi (default file manager + file picker) ─────────────────────────
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      yazi = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };

  # ── Default Applications (yazi as file manager) ───────────────────────
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
    };
  };

  xdg.desktopEntries.yazi = {
    name = "Yazi";
    comment = "Terminal file manager";
    exec = "ghostty -e yazi %F";
    icon = "system-file-manager";
    terminal = false;
    type = "Application";
    categories = [
      "System"
      "FileManager"
    ];
    mimeType = [ "inode/directory" ];
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
