# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands should be run from `~/.dotfiles/`.

```fish
rebuild   # sudo nixos-rebuild switch --flake .#nixos
update    # nix flake update
```

These are fish shell aliases defined in `home.nix`. Run them directly in the shell, or expand manually:

```bash
sudo nixos-rebuild switch --flake /home/owen/.dotfiles#nixos
nix flake update /home/owen/.dotfiles
```

There is no test command — changes are validated at rebuild time by Nix's type checker.

## Architecture

This is a NixOS flake-based system configuration for a single host (`nixos`) with home-manager integrated as a NixOS module.

**Entry point:** `flake.nix` defines all external inputs and wires them into a single `nixosConfigurations.nixos` output. The flake uses `nixpkgs-unstable`.

**Files:**

- `flake.nix` — inputs (nixpkgs, home-manager, DankMaterialShell, dgop, zen-browser, nix-citizen, nix-gaming, nixvim, walker, claude-code) and the single host output
- `configuration.nix` — NixOS system config: boot, networking, Hyprland compositor, DMS greeter, audio (Pipewire), Steam, QEMU/KVM, system packages, fonts, Wayland env vars
- `hardware-configuration.nix` — auto-generated hardware config (disk UUIDs, kernel modules); do not hand-edit
- `home.nix` — home-manager config for user `owen`: DankMaterialShell, Hyprland window manager, hypridle, hyprlock, Ghostty terminal, GTK theming, fish shell, starship prompt, git, yazi file manager
- `nixvim.nix` — NixVim (declarative Neovim) configuration imported by `home.nix`; provides a LazyVim-like setup with LSP, telescope, treesitter, conform, trouble, etc.

**Key flake inputs and their roles:**

| Input | Purpose |
|---|---|
| `dms` | DankMaterialShell — desktop shell/bar (bar, theming, notifications, lock screen) |
| `dgop` | System monitoring backend for DMS |
| `nixvim` | Declarative Neovim config as a home-manager module |
| `walker` | App launcher (replaces rofi/wofi) |
| `zen-browser` | Zen Browser (not in nixpkgs) |
| `nix-citizen` / `nix-gaming` | Star Citizen launcher + gaming support |
| `claude-code` | Claude Code CLI |

**Theming:** DMS uses matugen to derive a Material You palette from the current wallpaper and auto-generates color configs for Ghostty, Hyprland, Neovim, Zen Browser, Vesktop, GTK, and more. Do not hardcode colors in terminal/editor configs — DMS manages them.

**Display:** Single ultrawide monitor `DP-1` at 5120x1440@144Hz with 10-bit HDR. Hyprland uses the `scrolling` layout (niri-style column scrolling).

**Hyprland keybinds** use `SUPER` as `$mod`. Vim-style focus: `$mod+H/L` for column left/right, `$mod+J/K` for row up/down.
