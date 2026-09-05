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
    ./modules/system-packages.nix
    ./modules/system-extras.nix
  ];

  # ── Extra Filesystems ─────────────────────────────────────────────────
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/72e405b5-a7e0-4831-a612-44d729531d56";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
    ];
  };

  # ── Swap ──────────────────────────────────────────────────────────────
  # No swap partition exists (swapDevices is empty in hardware-configuration).
  # zram gives a compressed in-RAM cushion before the OOM killer fires, which
  # matters for Star Citizen / the Android emulator / VMs. Hibernate would
  # need a real swap device and is deliberately not set up.
  zramSwap.enable = true;

  # ── Nix Settings ──────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Binary caches: nix-citizen (Star Citizen wine builds) and numtide
      # (llm-agents.nix — claude-desktop, claude-code, codex, chatgpt).
      substituters = [
        "https://nix-citizen.cachix.org"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = [
        "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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

  # Disables AMD IOMMU. Required for Star Citizen stability — the SC anti-cheat
  # interacts badly with IOMMU on AMD platforms (random GPU resets / crashes).
  # Side-effects: no GPU passthrough to VMs, weaker DMA isolation. Re-enable
  # (delete this line) if you stop playing SC.
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
    # No initialPassword here on purpose — it renders into the world-readable
    # Nix store. The password is set imperatively via `passwd` and persists
    # because users.mutableUsers defaults to true. If this account ever needs
    # to be declared, use hashedPasswordFile pointing outside the store.
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "libvirtd"
      "kvm"
      "adbusers"
      "plugdev" # ZSA keyboard flashing (Oryx/Keymapp/Wally)
    ];
    shell = pkgs.fish;

    # Public keys allowed to SSH in as owen (see services.openssh below).
    # These come from the CLIENT you connect FROM — run `cat ~/.ssh/id_ed25519.pub`
    # there and paste the line here. Empty list = nobody can log in.
    openssh.authorizedKeys.keys = [
      # SHA256:ON43s2afEpyBLLddGuLC2v4WXO+KLVAaXDd1ZXWdBls
      # Added 2026-09-05. Key carried no comment field; rename this line if you
      # want it to say which client it belongs to.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE2kG6Jic5llmzoKrmoixvfGd+iATLQPxOrScqmI3Vd0"
    ];
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
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = "/home/owen";
    configFiles = [
      "/home/owen/.config/DankMaterialShell/settings.json"
    ];
  };

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
  # services.dbus.packages = [ pkgs.nautilus ];  # likely redundant — nautilus
  # ships its own dbus service files via environment.systemPackages. Re-enable
  # if file-manager dbus integration breaks.
  security.polkit.enable = true;

  # ── LACT (AMD GPU control) ───────────────────────────────────────────
  systemd.services = {
    lactd = {
      description = "LACT GPU Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.lact}/bin/lact daemon";
        Restart = "on-failure";
      };
    };
    disable-usb-wakeup = {
      description = "Disable USB controller wakeup sources";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "disable-usb-wakeup" ''
          for device in XHC0 XHC1 XHC2 XH00 UXHC; do
            if ${pkgs.gnugrep}/bin/grep -q "^$device.*enabled" /proc/acpi/wakeup; then
              echo "$device" > /proc/acpi/wakeup
            fi
          done
        '';
      };
    };
  };

  # ── Steam ────────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      gamescope
      mangohud
    ];
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # ── LocalSend ────────────────────────────────────────────────────────────
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # ---   # --- TailScale ------------------------------------------------------------
  services.tailscale = {
    enable = true;
  };

  # ── SSH server (inbound) ─────────────────────────────────────────────
  # Key-only auth. Keep password auth off — sudo here needs the account
  # password (wheelNeedsPassword), so a password-accepting sshd would put that
  # directly on the network. Client public keys go in authorizedKeys.keys
  # above; an empty list means nobody can log in, which is the safe failure
  # mode.
  services.openssh = {
    enable = true;
    openFirewall = false; # opened explicitly below instead
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  networking.firewall = {
    # Opens 22 on all interfaces — LAN-only in practice because this host sits
    # behind the router's NAT. Needed for clients not on the tailnet, e.g. strix.
    allowedTCPPorts = [ 22 ];
    # Tailnet. Redundant while the line above is present, but keeps SSH
    # reachable from the tailnet if LAN access is ever narrowed.
    interfaces.tailscale0.allowedTCPPorts = [ 22 ];
  };

  # ── System Packages ──────────────────────────────────────────────────
  # ── Android / Flutter Development ────────────────────────────────────
  # nix-ld provides a dynamic linker stub so pre-built FHS binaries
  # (Android emulator, Flutter tools) can run on NixOS without wrapping.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # X11 / XWayland (emulator UI runs via XWayland on Wayland compositors)
      libx11
      libxext
      libxrender
      libxrandr
      libxi
      libxcursor
      libxfixes
      libxcomposite
      libxdamage
      libxtst
      libxcb
      # OpenGL / Vulkan
      libGL
      mesa
      vulkan-loader
      # C++ / system runtime
      stdenv.cc.cc.lib
      zlib
      zstd
      # GLib / DBus
      glib
      dbus
      # Fonts / images
      freetype
      fontconfig
      libpng
      # Audio
      libpulseaudio
      alsa-lib
      # NSS / crypto (emulator network stack)
      nss
      nspr
      # Misc runtime
      libdrm
      libuuid
      curl
      expat
      libxml2
    ];
  };

  # System packages live in ./modules/system-packages.nix (managed by nixadd)
  # and ./modules/system-extras.nix (hand-edited).

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
    GDK_BACKEND = "wayland,x11";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    # Android SDK (populated by Android Studio on first run)
    ANDROID_HOME = "/home/owen/Android/Sdk";
    ANDROID_SDK_ROOT = "/home/owen/Android/Sdk";
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
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

  # ── Claude Desktop: Cowork micro-VM host support ─────────────────────
  # Cowork runs agent tasks in a QEMU/KVM guest launched by the desktop app.
  # It needs /dev/kvm and /dev/vhost-vsock; owen is in `kvm` above and udev
  # hands that group both nodes. vhost_vsock normally autoloads on first
  # open, but load it at boot so the app's launch-time check never races it.
  # QEMU and the UEFI firmware live inside the app's FHS env (see
  # modules/system-extras.nix) because bwrap hides the host /usr from it.
  boot.kernelModules = [ "vhost_vsock" ];

  # ── ZSA Keyboards (Voyager/Moonlander/Ergodox/Planck) ────────────────
  # Installs zsa-udev-rules (the official 50-zsa.rules) and creates the
  # plugdev group. The owen user is added to plugdev above so Oryx web
  # flashing, Keymapp, and Wally can access the keyboard.
  hardware.keyboard.zsa.enable = true;

  # ── Misc Services ────────────────────────────────────────────────────
  services.gvfs.enable = true; # Trash, network mounts in file manager
  services.accounts-daemon.enable = true; # For DMS user avatar
  services.power-profiles-daemon.enable = true; # Power management

  system.stateVersion = "24.11"; # Do NOT change after initial install
}
