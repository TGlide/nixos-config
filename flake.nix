{
  description = "Flake ❆";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

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
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # this is a quick util a good GitHub samaritan wrote to solve for
    # https://github.com/nix-community/home-manager/issues/1341#issuecomment-1791545015
    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    textfox.url = "github:adriankarlen/textfox";

    ghostty = {
      url = "github:ghostty-org/ghostty";
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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ghostty,
    hyprpanel,
    nix-darwin,
    ags,
    ...
  } @ inputs: let
    inherit (self) outputs;
    x86_64-linux = "x86_64-linux";
    aarch64-darwin = "aarch64-darwin"; # For Apple Silicon Macs
    x86_64-linux-pkgs = nixpkgs.legacyPackages.${x86_64-linux};
  in {
    packages.${x86_64-linux}.default = ags.lib.bundle {
      inherit x86_64-linux-pkgs;
      src = ./.;
      name = "my-shell"; # name of executable
      entry = "app.ts";
      gtk4 = false;

      # additional libraries and executables to add to gjs' runtime
      extraPackages = [
        # ags.packages.${system}.battery
        # pkgs.fzf
      ];
    };

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = x86_64-linux;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./nixos/configuration.nix

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
                ./home-manager/shared.nix
                ./home-manager/nixos.nix
              ];
            };
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit inputs;};
          }

          # Add Ghostty as a system package
          {
            environment.systemPackages = [
              ghostty.packages.x86_64-linux.default
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
                ./home-manager/shared.nix
                ./home-manager/darwin.nix
              ];
            };
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
          # Add Ghostty as a system package
          # {
          #   environment.systemPackages = [
          #     ghostty.packages.aarch64-darwin.default # or x86_64-darwin for Intel
          #   ];
          # }
        ];
      };
    };
  };
}
