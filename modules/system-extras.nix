{
  pkgs,
  inputs,
  system,
  ...
}:

# System packages that aren't bare `pkgs.<name>` references — flake inputs,
# overrides, wrapper derivations, etc. Hand-edited; nixadd never touches this.

let
  llm = inputs.llm-agents.packages.${system};

  # Cowork's guest VM needs UEFI firmware at the Debian path
  # /usr/share/OVMF/OVMF_CODE_4M.fd (hardcoded upstream, no env override) and
  # qemu-system-x86_64 on PATH. The llm-agents package runs inside a
  # buildFHSEnv whose bind-mounted /usr shadows the host's, so host-side
  # tmpfiles symlinks are invisible to it — the files have to live inside the
  # env. This derivation mirrors the layout `apt install ovmf` provides.
  ovmf-debian-layout = pkgs.runCommandLocal "ovmf-debian-layout" { } ''
    mkdir -p $out/share/OVMF
    ln -s ${pkgs.OVMF.firmware}  $out/share/OVMF/OVMF_CODE_4M.fd
    ln -s ${pkgs.OVMF.variables} $out/share/OVMF/OVMF_VARS_4M.fd
  '';

  # Chromium only auto-selects a keyring backend on GNOME/KDE. Under Hyprland it
  # tries the xdg-desktop-portal Secret API, fails, and stores nothing
  # ("safeStorage not available, tokens will not persist" in main.log). Point it
  # at libsecret explicitly; services.gnome.gnome-keyring in configuration.nix
  # provides the org.freedesktop.secrets service it talks to.
  claude-desktop-upstream = llm.claude-desktop.override {
    commandLineArgs = "--password-store=gnome-libsecret";
  };

  # Re-run buildFHSEnv with the Cowork bits added. `.args` is the exact attrset
  # llm-agents passed to buildFHSEnv, so this keeps tracking upstream changes
  # to the wrapper (GPU libs, runScript, etc.) without copying them here.
  claude-desktop = pkgs.buildFHSEnv (
    claude-desktop-upstream.args
    // {
      targetPkgs =
        p:
        (claude-desktop-upstream.args.targetPkgs p)
        ++ [
          pkgs.qemu_kvm
          ovmf-debian-layout
        ];
    }
  );
in
{
  environment.systemPackages = [
    # Zen Browser from flake
    inputs.zen-browser.packages.${system}.default

    # Claude Desktop — Anthropic's official Linux .deb via llm-agents, with
    # QEMU + OVMF folded into its FHS env so the Cowork tab works.
    claude-desktop

    # ChatGPT / Codex desktop app via llm-agents
    llm.chatgpt
  ];

  # The modrinth-app `wrapGAppsHook` bash-5.3 workaround that lived here was
  # removed on 2026-09-05: upstream now uses the split hooks
  # (gappsWrapperArgsHook + wrapGApp) instead of calling wrapGAppsHook manually,
  # so the empty-$output array subscript no longer occurs.
}
