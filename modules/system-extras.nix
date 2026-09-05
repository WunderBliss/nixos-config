{
  pkgs,
  inputs,
  system,
  ...
}:

# System packages that aren't bare `pkgs.<name>` references — flake inputs,
# overrides, wrapper derivations, etc. Hand-edited; nixadd never touches this.

{
  environment.systemPackages = [
    # Zen Browser from flake
    inputs.zen-browser.packages.${system}.default
    # Claude Desktop from flake
    # inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
  ];

  # The modrinth-app `wrapGAppsHook` bash-5.3 workaround that lived here was
  # removed on 2026-09-05: upstream now uses the split hooks
  # (gappsWrapperArgsHook + wrapGApp) instead of calling wrapGAppsHook manually,
  # so the empty-$output array subscript no longer occurs.
}
