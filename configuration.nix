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
    ./hardware-configuration.nix
  ];

  # ── Nix Settings ──────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # nix-citizen binary cache (Star Citizen wine builds)
      substituters = [
        "https://nix-citizen.cachix.org"
        "https://claude-code.cachix.org"
      ];
      trusted-public-keys = [
        "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # ── Kernel Tuning (required for Star Citizen) ─────────────────────────
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216; # SC needs a high mmap limit
    "fs.file-max" = 524288; # High open file descriptor limit
  };

  boot.kernelParams = [ "amd_iommu=off" ];

  # ── Bootloader (systemd-boot) ────────────────────────────────────────
  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # ── Filesystem ────────────────────────────────────────────────────────
  # ext4 filesystem — partitions defined in hardware-configuration.nix

  # ── Networking ────────────────────────────────────────────────────────
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # ── Locale & Time ────────────────────────────────────────────────────
  time.timeZone = "Asia/Tokyo"; # Adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Unfree Packages ──────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── User ──────────────────────────────────────────────────────────────
  users.users.owen = {
    isNormalUser = true;
    description = "Owen";
    initialPassword = "owen";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "libvirtd"
      "kvm"
    ];
    shell = pkgs.fish;
  };

  # ── Fish Shell (system-wide enable so it's in /etc/shells) ───────────
  programs.fish.enable = true;

  # ── Hyprland (Wayland Compositor) ─────────────────────────────────────
  programs.hyprland = {
    enable = true;
    # Uses the nixpkgs-unstable package — no flake needed.
    # The NixOS module generates a wayland-sessions .desktop entry.
    # Ensure it invokes start-hyprland (not bare Hyprland) for crash
    # recovery and safe mode.  Recent nixpkgs packages should do this
    # automatically.  If not, you can override with a custom .desktop
    # entry in /usr/share/wayland-sessions/.
    xwayland.enable = true;
  };

  # ── Display Manager — dms-greeter via greetd ─────────────────────────
  # ⚠ VERIFY: confirm DMS greeter supports compositor.name = "hyprland"
  # and that it invokes start-hyprland (not bare Hyprland) for the session.
  # If the greeter doesn't use start-hyprland automatically, you may need:
  #   compositor.command = "start-hyprland";
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = "/home/owen";
    configFiles = [
      "/home/owen/.config/DankMaterialShell/settings.json"
    ];
  };

  # ── Fallback: greetd session command ──────────────────────────────────
  # If DMS greeter doesn't support compositor.name for Hyprland, or
  # doesn't use start-hyprland, you can configure greetd directly:
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "start-hyprland";
  #       user = "owen";
  #     };
  #   };
  # };

  # ── XWayland (Hyprland handles this natively) ────────────────────────
  programs.xwayland.enable = true;

  # ── Portal / Desktop Integration ──────────────────────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
    config = {
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
    };
  };

  # ── Pipewire (Audio) ─────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── D-Bus & Polkit ───────────────────────────────────────────────────
  services.dbus.packages = [ pkgs.nautilus ];
  security.polkit.enable = true;

  # ── LACT (AMD GPU control) ───────────────────────────────────────────
  systemd.services.lactd = {
    description = "LACT GPU Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "on-failure";
    };
  };

  # ── Steam ────────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # ── System Packages ──────────────────────────────────────────────────
  environment.systemPackages =
    with pkgs;
    [
      git
      neovim
      lazygit
      ghostty
      obsidian
      protonvpn-gui
      lact
      yazi
      protonup-qt
      wl-clipboard # Wayland clipboard utils
      nautilus # Needed for portal-gnome file chooser fallback
      brightnessctl # Backlight control
      playerctl # MPRIS media control
      networkmanagerapplet
      glib # gsettings for GTK theming
      adw-gtk3 # GTK3 theme that DMS matugen can target
      adwaita-icon-theme # Fallback icons
      fish # Default shell
      starship # Prompt
      grimblast # Screenshot tool for Hyprland (replaces niri built-in)
      slurp # Region selection for screenshots
      grim # Base screenshot utility
      hyprpicker # Color picker for Hyprland
      vesktop
      fastfetch
      virt-viewer # SPICE/VNC display client for VMs
    ]
    ++ [
      # Zen Browser from flake
      inputs.zen-browser.packages.${system}.default
    ];

  # 1password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "owen" ];
  };
  # ── Fonts ────────────────────────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  # ── Environment Variables (Wayland best practices) ────────────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron apps → Wayland
    MOZ_ENABLE_WAYLAND = "1"; # Firefox/Zen → Wayland
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    GDK_BACKEND = "wayland,x11";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  # ── xdg-desktop-portal-termfilechooser config ────────────────────────
  # Tells the termfilechooser portal to use yazi via ghostty
  environment.etc."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.ghostty}/bin/ghostty --class=yazi-picker -e ${pkgs.writeShellScript "yazi-picker" ''
      #!/usr/bin/env bash
      # $1 = path written by the portal for the result
      set -euo pipefail
      path="$1"
      chosen="$(yazi --chooser-file=/dev/stdout)"
      if [ -n "$chosen" ]; then
        echo "$chosen" > "$path"
      fi
    ''}
  '';

  # ── Virtualisation (QEMU/KVM + virt-manager) ─────────────────────────
  # Note: GPU passthrough is not possible because amd_iommu=off is set.
  # A standard Windows VM with VirtIO drivers works fine without it.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true; # TPM emulation (required for Windows 11)
    };
  };
  programs.virt-manager.enable = true;

  # ── Misc Services ────────────────────────────────────────────────────
  services.gvfs.enable = true; # Trash, network mounts in file manager
  services.accounts-daemon.enable = true; # For DMS user avatar
  services.power-profiles-daemon.enable = true; # Power management

  system.stateVersion = "24.11"; # Do NOT change after initial install
}
