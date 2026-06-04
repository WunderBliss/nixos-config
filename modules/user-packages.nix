{ pkgs, ... }:

# User packages (home-manager). Same conventions as system-packages.nix.
#
# ⚠ MANAGED FILE — the `nixadd` utility edits the list below.
# For wrapper derivations and flake-input packages, use ./user-extras.nix.

{
  home.packages = with pkgs; [
    # BEGIN NIXADD
    comma # Run packages without installing: `, cowsay hi`
    gh
    mangojuice
    nodejs_22
    pnpm
    r2modman
    stripe-cli
    supabase-cli
    xivlauncher
    # END NIXADD
  ];
}
