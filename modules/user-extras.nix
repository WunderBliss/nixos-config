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
    # Star Citizen via nix-citizen (LUG recommended for NixOS).
    #
    # Wrapped in wl-veil (from wl-proxy) so the game never sees the
    # zwp_text_input_manager_v3 global. SC runs on Wine's native Wayland
    # driver, which enables text-input for every focused window
    # unconditionally (winewayland.drv/wayland_text_input.c; only fixed
    # upstream by Wine MR !10007, not in wine-astral 11.16). Hyprland then
    # activates fcitx5, fcitx5 grabs the keyboard and emulates key repeat as
    # release/press pairs, so any held key flaps in-game. With the global
    # hidden Wine logs "host input methods won't work" for this process only;
    # fcitx5 keeps working in every other window. wl-veil exits when the
    # launcher script exits, and that script ends with `wineserver -w`, so
    # the proxy lives as long as any Wine process in the prefix.
    (
      let
        rsi = inputs.nix-citizen.packages.${system}.rsi-launcher;
      in
      pkgs.symlinkJoin {
        name = "rsi-launcher-veiled";
        paths = [ rsi ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        # The .desktop entry uses a bare `Exec=rsi-launcher`, so replacing the
        # bin/ entry is enough to route the desktop launcher through the veil.
        postBuild = ''
          rm "$out/bin/rsi-launcher"
          makeWrapper ${pkgs.wl-proxy}/bin/wl-veil "$out/bin/rsi-launcher" \
            --add-flags "-f zwp_text_input_manager_v3 --" \
            --add-flags "${rsi}/bin/rsi-launcher"
        '';
      }
    )

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
