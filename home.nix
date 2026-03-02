{ config, pkgs, inputs, system, lib, ... }:

{
  imports = [
    # NixVim home-manager module
    inputs.nixvim.homeManagerModules.nixvim

    # DankMaterialShell home-manager module
    inputs.dms.homeModules.dank-material-shell

    # ⚠ VERIFY: Does DMS expose a homeModules.hyprland?
    # If not, remove this line and handle Hyprland startup/keybinds manually.
    # The niri equivalent was: inputs.dms.homeModules.niri
    inputs.dms.homeModules.hyprland

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
      inputs.nix-citizen.packages.${system}.rsi-launcher  # Recommended package
      inputs.nix-citizen.packages.${system}.lug-helper     # LUG Helper tool
    ];
  };

  # ── DankMaterialShell ─────────────────────────────────────────────────
  # DMS handles ALL theming via matugen + dank16.  It auto-generates:
  #   • GTK 3/4 css (dank-colors.css)  • Qt themes
  #   • Terminal palettes (ghostty, kitty, alacritty, foot, wezterm)
  #   • Editor themes (vscode/vscodium)  • Zen/Firefox userChrome.css
  # Colors are derived from your wallpaper on every wallpaper change.
  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;   # ← matugen wallpaper-based theming
    enableAudioWavelength = true;
    enableClipboardPaste = true;
    dgop.package = inputs.dgop.packages.${system}.default;

    # ⚠ VERIFY: This block assumes DMS has a hyprland integration section
    # mirroring the niri one.  If DMS doesn't support Hyprland natively,
    # remove this block and instead:
    #   1. Launch DMS manually in Hyprland's exec-once
    #   2. Handle keybind integration yourself
    hyprland = {
      includes = {
        enable = true;
        override = true;
        originalFileName = "hm";
      };
      enableSpawn = true; # Auto-start DMS with Hyprland
    };

    # Default DMS settings (dark mode, dynamic theming on)
    settings = {
      theme = "dark";
      dynamicTheming = true;
    };
  };

  # niri-flake polkit line removed — not applicable to Hyprland
  # If Hyprland's flake ships a polkit agent you don't want, disable it
  # here similarly (check hyprland flake docs).

  # ── Hyprland Configuration ────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    # Uses the nixpkgs package (set by programs.hyprland.enable in configuration.nix)
    # systemd.enable integrates Hyprland with the systemd user session
    # (environment propagation, graphical-session.target activation).
    # This is the recommended path — UWSM is not used here as upstream
    # considers it experimental and it conflicts with this setting.
    systemd.enable = true;

    # ── Plugins ───────────────────────────────────────────────────────
    # Option A: If hyprlandPlugins.hyprspace is in your nixpkgs:
    #   plugins = [ pkgs.hyprlandPlugins.hyprspace ];
    # Option B: From flake input (remove if Option A works):
    plugins = [
      inputs.hyprspace.packages.${system}.Hyprspace
    ];

    settings = {

      # ── General ─────────────────────────────────────────────────────
      general = {
        gaps_in = 4;          # niri gaps=8 → split between inner/outer
        gaps_out = 8;
        border_size = 2;

        # Scrolling layout! This is the feature you're after.
        # ⚠ VERIFY: The exact layout name — it may be "scroller" or
        # require a plugin depending on your Hyprland version.
        # Per-workspace layouts can be set with workspace rules below.
        layout = "scroller";

        # Allow window resizing/moving by dragging borders
        resize_on_border = true;
      };

      # ── Per-Workspace Layout (Hyprland's new feature) ───────────────
      # You can override layout per-workspace.  Example:
      # workspace = [
      #   "1, layout:scroller"
      #   "2, layout:dwindle"
      #   "3, layout:scroller"
      # ];

      # ── Input ───────────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        follow_mouse = 1;        # focus-follows-mouse (like niri)
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
          enabled = true;        # niri had shadow.enable = true
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
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

      # ── Scroller Layout Settings ────────────────────────────────────
      # ⚠ VERIFY: these options depend on your Hyprland version.
      # The scroller layout is relatively new — check the wiki for
      # available configuration keys.
      # plugin = {
      #   scroller = {
      #     column_default_width = "onehalf";
      #     focus_wrap = true;
      #     center_active_column = "on-overflow";  # mirrors niri
      #   };
      # };

      # ── Window Rules ────────────────────────────────────────────────
      windowrulev2 = [
        # Polkit / audio popups float (was niri: authentication-agent-1|pwvucontrol)
        "float, class:^(authentication-agent-1)$"
        "float, class:^(pwvucontrol)$"

        # Steam floats
        "float, class:^(steam)$"
        "float, title:^(Steam)$"

        # Yazi file picker (spawned by xdg-desktop-portal-termfilechooser)
        "float, class:^(yazi-picker)$"
        "move 300 200, class:^(yazi-picker)$"
      ];

      # ── Startup ─────────────────────────────────────────────────────
      # xwayland-satellite removed — Hyprland has native XWayland
      exec-once = [
        # If DMS auto-start (enableSpawn) doesn't work, launch it here:
        # "dank-material-shell"
      ];

      # ── Keybindings ─────────────────────────────────────────────────
      "$mod" = "SUPER";

      bind = [
        # ── App Launchers ──────────────────────────────────────────
        "$mod, Return, exec, ghostty"
        "$mod, E, exec, ghostty --class=yazi -e yazi"
        "$mod, B, exec, zen"

        # ── Window Management ──────────────────────────────────────
        "$mod, Q, killactive"
        "$mod SHIFT, E, exit"

        # ── Focus (vim keys — same as your niri setup) ─────────────
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, Left, movefocus, l"
        "$mod, Right, movefocus, r"
        "$mod, Down, movefocus, d"
        "$mod, Up, movefocus, u"

        # ── Move Windows ───────────────────────────────────────────
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"

        # ── Sizing ─────────────────────────────────────────────────
        # niri had set-column-width ±10%; Hyprland uses resizeactive
        "$mod, minus, resizeactive, -80 0"
        "$mod, equal, resizeactive, 80 0"
        "$mod, F, fullscreen, 1"          # Maximize (keep bar)
        "$mod SHIFT, F, fullscreen, 0"    # True fullscreen
        "$mod, C, centerwindow"

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
        "$mod, O, overview:toggle"

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
        "$mod, mouse:272, movewindow"     # Super + LMB to drag
        "$mod, mouse:273, resizewindow"   # Super + RMB to resize
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
    categories = [ "System" "FileManager" ];
    mimeType = [ "inode/directory" ];
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
