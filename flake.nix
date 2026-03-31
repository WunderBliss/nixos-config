{
  description = "Owen's NixOS — Hyprland + DankMaterialShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprspace – overview plugin for Hyprland
    # If hyprlandPlugins.hyprspace exists in your nixpkgs, you can remove
    # this input and use the nixpkgs version instead (simpler).
    # hyprspace = {
    #  url = "github:KZDKM/Hyprspace";
    #  inputs.hyprland.follows = "nixpkgs";
    #};

    # DankMaterialShell – desktop shell
    # ⚠ VERIFY: confirm DMS has Hyprland support (homeModules.hyprland)
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dgop – system monitoring backend for DMS
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Star Citizen (nix-citizen flake — LUG recommended for NixOS)
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-gaming.follows = "nix-gaming";
    };
    # Latest nix-gaming for up-to-date DXVK/vkd3d
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixVim – declarative Neovim configuration
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #Walker / Elephant
    elephant.url = "github:abenz1267/elephant";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    # Claude Code
    claude-code.url = "github:sadjow/claude-code-nix";

    # Claude Desktop
    #claude-desktop = {
    #url = "github:k3d3/claude-desktop-linux-flake";
    #inputs.nixpkgs.follows = "nixpkgs";
    #};

    # Claude desktop bin
    claude-desktop-bin = {
      url = "github:patrickjaja/claude-desktop-bin";
    };

    # Claude Cowork
    claude-cowork-service = {
      url = "github:patrickjaja/claude-cowork-service";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      dms,
      dgop,
      zen-browser,
      nix-citizen,
      nix-gaming,
      nixvim,
      walker,
      claude-desktop-bin,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs system; };
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix

          # Home-manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = {
                inherit inputs system;
                inherit claude-desktop-bin;
              };
              users.owen = import ./home.nix;
            };
          }
        ];
      };
    };
}
