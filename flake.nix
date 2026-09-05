{
  description = "Owen's NixOS — Hyprland + DankMaterialShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankMaterialShell – desktop shell
    # ⚠ VERIFY: confirm DMS has Hyprland support (homeModules.hyprland)
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
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

    # AI agent tooling (numtide): Claude Desktop, Claude Code, Codex, ChatGPT
    # desktop, and ~180 others, bumped by CI as upstream releases land.
    # claude-desktop is Anthropic's official Linux .deb repackaged with
    # autoPatchelf + buildFHSEnv. Deliberately NOT following our nixpkgs:
    # numtide's binary cache (configuration.nix) only hits on their pin.
    llm-agents.url = "github:numtide/llm-agents.nix";

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      dms,
      zen-browser,
      nix-citizen,
      nix-gaming,
      nixvim,
      walker,
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
      formatter.${system} = pkgs.nixfmt;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs system; };
        modules = [
          # hardware-configuration.nix is imported by configuration.nix, which
          # is the machine-specific half of this pair.
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
              };
              users.owen = import ./home.nix;
            };
          }
        ];
      };
    };
}
