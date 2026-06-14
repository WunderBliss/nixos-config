{ pkgs, ... }:

# System-wide packages installed for all users.
#
# ⚠ MANAGED FILE — the `nixadd` utility edits the list below.
# Keep the structure exactly as shown:
#   - Single `environment.systemPackages = with pkgs; [ ... ];` binding
#   - One bare attribute per line, alphabetised
#   - Nothing between the BEGIN/END NIXADD markers other than packages & comments
#
# For wrapper derivations, flake-input packages, overrides, or anything that
# isn't a bare `pkgs.<name>` reference, use ./system-extras.nix instead.

{
  environment.systemPackages = with pkgs; [
    # BEGIN NIXADD
    adw-gtk3 # GTK3 theme that DMS matugen can target
    adwaita-icon-theme # Fallback icons
    alejandra # Nix formatter (used by nixadd after edits)
    android-studio
    android-tools
    brightnessctl # Backlight control
    fastfetch
    fish # Default shell
    flutter
    ghostty
    git
    glib # gsettings for GTK theming
    godot_4
    grim # Base screenshot utility
    grimblast # Screenshot tool for Hyprland (replaces niri built-in)
    haskellPackages.pandoc-cli
    hyprpicker # Color picker for Hyprland
    jdk17
    lact
    lazygit
    modrinth-app
    nautilus # Needed for portal-gnome file chooser fallback
    neovim
    networkmanagerapplet
    nh # Better nixos-rebuild wrapper
    nix-output-monitor # Pretty build progress (used by nh automatically)
    nix-tree # Inspect closures / find bloat
    nvd # Diff generations after a rebuild
    nixfmt-rfc-style # Official Nix formatter
    obsidian
    playerctl # MPRIS media control
    protonup-qt
    protonvpn-gui
    slurp # Region selection for screenshots
    starship # Prompt
    vesktop
    virt-viewer # SPICE/VNC display client for VMs
    wl-clipboard # Wayland clipboard utils
    yazi
    zip
    freerdp
    kitty
    hyprlauncher
    # END NIXADD
  ];
}
