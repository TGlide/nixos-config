{
  description = "Flake ❆";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    helix.url = "github:helix-editor/helix/master";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # this is a quick util a good GitHub samaritan wrote to solve for
    # https://github.com/nix-community/home-manager/issues/1341#issuecomment-1791545015
    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager"; # Add this line
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    swww.url = "github:LGFae/swww";

    matugen = {
      url = "github:/InioX/Matugen";
      # If you need a specific version:
      # ref = "refs/tags/matugen-v0.10.0";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    hyprpanel,
    nix-darwin,
    ags,
    ...
  } @ inputs: let
    inherit (self) outputs;

    x86_64-linux = "x86_64-linux";
    x86_64-linux-pkgs = nixpkgs.legacyPackages.${x86_64-linux};
    x86_64-linux-unstable-pkgs = import nixpkgs-unstable {
      system = x86_64-linux;
      config.allowUnfree = true;
    };

    aarch64-darwin = "aarch64-darwin"; # For Apple Silicon Macs
    aarch64-darwin-unstable-pkgs = import nixpkgs-unstable {
      system = aarch64-darwin;
      config.allowUnfree = true;
    };
  in {
    packages.${x86_64-linux}.denki-shell = ags.lib.bundle {
      pkgs = x86_64-linux-pkgs;
      src = ./ags;
      name = "denki-shell";
      entry = "app.ts";
      gtk4 = false;
      extraPackages = [
        ags.packages.${x86_64-linux}.hyprland
        ags.packages.${x86_64-linux}.mpris
        ags.packages.${x86_64-linux}.wireplumber
        ags.packages.${x86_64-linux}.tray
        ags.packages.${x86_64-linux}.notifd
      ];
    };

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = x86_64-linux;
        specialArgs = {
          inherit inputs outputs;
          unstable = x86_64-linux-unstable-pkgs;
        };
        modules = [
          ./nixos/configuration.nix

          inputs.agenix.nixosModules.default

          # Overlays
          {
            nixpkgs.overlays = [hyprpanel.overlay] ++ import ./overlays;
          }

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thomasgl = {
              imports = [
                inputs.spicetify-nix.homeManagerModules.default
                ./home-manager/shared.nix
                ./home-manager/nixos.nix
              ];
            };
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit inputs;
              unstable = x86_64-linux-unstable-pkgs;
            };
          }

          {
            environment.systemPackages = [
              self.packages.${x86_64-linux}.denki-shell # Reference it here
              inputs.agenix.packages.x86_64-linux.default
            ];
          }
        ];
      };
    };

    darwinConfigurations = {
      float = nix-darwin.lib.darwinSystem {
        system = aarch64-darwin;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Your darwin configuration
          ./darwin/configuration.nix
          # Home-manager darwin module
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thomasglopes = {
              imports = [
                inputs.spicetify-nix.homeManagerModules.default
                ./home-manager/shared.nix
                ./home-manager/darwin.nix
              ];
            };
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit inputs;
              unstable = aarch64-darwin-unstable-pkgs;
            };
          }
        ];
      };

      pro = nix-darwin.lib.darwinSystem {
        system = aarch64-darwin;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Your darwin configuration
          ./darwin/configuration.nix
          # Home-manager darwin module
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thomasglopes = {
              imports = [
                inputs.spicetify-nix.homeManagerModules.default
                ./home-manager/shared.nix
                ./home-manager/darwin.nix
              ];
            };
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit inputs;
              unstable = aarch64-darwin-unstable-pkgs;
            };
          }
        ];
      };
    };

    # Home Manager standalone configuration for generic Linux systems
    homeConfigurations = {
      thomasgl = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_64-linux}.extend (final: prev: {
          nixpkgs.overlays = import ./overlays;
        });
        extraSpecialArgs = {
          inherit inputs;
          unstable = x86_64-linux-unstable-pkgs;
        };
        modules = [
          ./home-manager/shared.nix
          ./home-manager/linux.nix
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = import ./overlays;
            home.stateVersion = "24.11";
          }
        ];
      };
    };
  };
}
