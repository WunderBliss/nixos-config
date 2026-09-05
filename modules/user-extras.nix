{
  pkgs,
  inputs,
  system,
  ...
}:

# User packages that aren't bare `pkgs.<name>` references — flake inputs,
# wrapper scripts, symlinkJoin compositions. Hand-edited; nixadd never touches.

{
  home.packages = [
    # Star Citizen via nix-citizen (LUG recommended for NixOS)
    inputs.nix-citizen.packages.${system}.rsi-launcher
    # inputs.nix-citizen.packages.${system}.lug-helper

    # AI coding CLIs via llm-agents (numtide). Desktop apps (Claude Desktop,
    # ChatGPT) are system packages in ./system-extras.nix.
    inputs.llm-agents.packages.${system}.claude-code
    inputs.llm-agents.packages.${system}.codex

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
            libxkbfile
            libsm
            libice
            libxcb
            libxkbcommon
            xcb-util-cursor
            libxcb-image
            libxcb-keysyms
            libxcb-render-util
            libxcb-wm
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
