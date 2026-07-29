{
  pkgs,
  inputs,
  system,
  #claude-desktop-bin,
  ...
}:

# User packages that aren't bare `pkgs.<name>` references — flake inputs,
# wrapper scripts, symlinkJoin compositions. Hand-edited; nixadd never touches.

{
  home.packages = [
    # Star Citizen via nix-citizen (LUG recommended for NixOS)
    inputs.nix-citizen.packages.${system}.rsi-launcher
    # inputs.nix-citizen.packages.${system}.lug-helper

    inputs.claude-code.packages.${system}.default
    #claude-desktop-bin.packages.${system}.default

    # Godot wrapper: clears stale D-Bus screensaver inhibitor after exit
    (pkgs.writeShellScriptBin "godot-launcher" ''
      godot4 "$@"
      systemctl --user restart hypridle
    '')

    # Android emulator wrapper: merges all needed libs into one dir so
    # LD_LIBRARY_PATH stays short. No bwrap/namespaces required.
    # Usage: android-emulator -avd <avd-name>
    (
      let
        emuLibs = pkgs.symlinkJoin {
          name = "android-emulator-libs";
          paths = with pkgs; [
            xorg.libX11
            xorg.libXext
            xorg.libXrender
            xorg.libXrandr
            xorg.libXi
            xorg.libXcursor
            xorg.libXfixes
            xorg.libXcomposite
            xorg.libXdamage
            xorg.libXtst
            xorg.libxkbfile
            xorg.libSM
            xorg.libICE
            libxcb
            libxkbcommon
            xcb-util-cursor
            xorg.xcbutilimage
            xorg.xcbutilkeysyms
            xorg.xcbutilrenderutil
            xorg.xcbutilwm
            libGL
            mesa
            vulkan-loader
            stdenv.cc.cc.lib
            zlib
            zstd
            glib
            dbus
            freetype
            fontconfig
            libpng
            pixman
            bzip2
            nss
            nspr
            libdrm
            libuuid
            curl
            expat
            libxml2
            libbsd
            libepoxy
            libslirp
            libcap_ng
            libseccomp
            numactl
            alsa-lib
            libpulseaudio
          ];
        };
      in
      pkgs.writeShellScriptBin "android-emulator" ''
        export LD_LIBRARY_PATH="${emuLibs}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        export QT_QPA_PLATFORM=xcb
        exec "$HOME/Android/Sdk/emulator/emulator.bin" "$@"
      ''
    )
  ];
}
