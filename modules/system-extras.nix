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
}
