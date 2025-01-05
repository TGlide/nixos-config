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
    textfox.url = "github:adriankarlen/textfox";

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ghostty,
    # hyprland,
    hyprpanel,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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

            home-manager.users.thomasgl = import ./home-manager/home.nix;

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

    # homeConfigurations = {
    #   "thomasgl@nixos" = home-manager.lib.homeManagerConfiguration {
    #     modules = [
    #       {
    #         wayland.windowManager.hyprland = {
    #           enable = true;
    #           # set the flake package
    #           package = inputs.hyprland.packages.${nixpkgs.legacyPackages.x86_64-linux.stdenv.hostPlatform.system}.hyprland;
    #         };
    #       }
    #       # ...
    #     ];
    #   };
    # };
  };
}
