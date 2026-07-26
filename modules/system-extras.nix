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

  # ── TEMPORARY WORKAROUND — remove once upstream nixpkgs fixes this ──
  # bash 5.3 made empty associative-array subscripts a fatal "bad array
  # subscript" error (bash 5.2 tolerated them). modrinth-app is a symlinkJoin
  # that calls the `wrapGAppsHook` shell function manually in postBuild, where
  # $output is still empty, tripping wrap-gapps-hook.sh:67. Give $output a value
  # for that one call so the dedup-guard subscript is non-empty.
  # The `assert` makes eval fail loudly (instead of silently no-op'ing) if a
  # future nixpkgs bump restructures modrinth's buildCommand.
  # Track: modrinth's package.nix should stop calling wrapGAppsHook manually, or
  # wrap-gapps-hook.sh should guard the empty subscript.
  nixpkgs.overlays = [
    (final: prev: {
      modrinth-app = prev.modrinth-app.overrideAttrs (
        old:
        let
          patched = builtins.replaceStrings
            [ "\nwrapGAppsHook" ]
            [ "\noutput=\${output:-out}\nwrapGAppsHook" ]
            old.buildCommand;
        in
        {
          buildCommand = assert patched != old.buildCommand; patched;
        }
      );
    })
  ];
}
