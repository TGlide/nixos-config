# NixOS Configuration

This repository contains Nix configurations for multiple systems:

- NixOS system
- macOS (Darwin) systems
- Generic Linux systems (e.g., Arch Linux)

## Setup for Different Systems

### NixOS

For NixOS, use the following command to apply the configuration:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### macOS (Darwin)

For macOS systems, use the following command to apply the configuration:

```bash
nix run nix-darwin -- switch --flake .#float  # For the 'float' configuration
# OR
nix run nix-darwin -- switch --flake .#pro    # For the 'pro' configuration
```

### Generic Linux (e.g., Arch Linux)

For generic Linux systems, you need to:

1. Install Nix package manager:

   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. Enable flakes (if not already enabled):

   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

3. Install home-manager:

   ```bash
   nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
   nix-channel --update
   ```

4. Apply the home-manager configuration:
   ```bash
   nix run home-manager/release-24.11 -- switch --flake .#thomasgl
   ```

## Structure

- `flake.nix`: Main configuration file
- `nixos/`: NixOS-specific configuration
- `darwin/`: macOS-specific configuration
- `home-manager/`: User configuration
  - `shared.nix`: Shared configuration for all systems
  - `nixos.nix`: NixOS-specific user configuration
  - `darwin.nix`: macOS-specific user configuration
  - `linux.nix`: Generic Linux-specific user configuration
- `overlays/`: Package overlays
- `packages/`: Custom packages
- `scripts/`: Utility scripts

## Customization

To customize the configuration for your own use:

1. Update usernames and home directories in the respective configuration files
2. Modify package lists and configurations as needed
3. Add or remove overlays as required
