#!/usr/bin/env bash

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to ask for confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}=== Nix Setup for Generic Linux Systems ===${NC}"
echo -e "${YELLOW}This script will guide you through setting up Nix and home-manager on your Linux system.${NC}"
echo -e "${YELLOW}You will be asked before each step, so you can skip steps you've already completed.${NC}"
echo

# Step 1: Install Nix
if command_exists nix; then
    echo -e "${GREEN}Nix is already installed.${NC}"
else
    if confirm "Would you like to install Nix package manager?"; then
        echo -e "${BLUE}Installing Nix...${NC}"
        sh <(curl -L https://nixos.org/nix/install) --daemon
        
        # Source nix profile to make nix commands available in current session
        if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
            . ~/.nix-profile/etc/profile.d/nix.sh
        fi
        
        echo -e "${GREEN}Nix installed successfully.${NC}"
    else
        echo -e "${YELLOW}Skipping Nix installation.${NC}"
    fi
fi

# Step 2: Enable flakes
if [ -f ~/.config/nix/nix.conf ] && grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf; then
    echo -e "${GREEN}Flakes are already enabled.${NC}"
else
    if confirm "Would you like to enable Nix flakes?"; then
        echo -e "${BLUE}Enabling flakes...${NC}"
        mkdir -p ~/.config/nix
        if [ -f ~/.config/nix/nix.conf ]; then
            if ! grep -q "experimental-features" ~/.config/nix/nix.conf; then
                echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
            fi
        else
            echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
        fi
        echo -e "${GREEN}Flakes enabled successfully.${NC}"
    else
        echo -e "${YELLOW}Skipping flakes setup.${NC}"
    fi
fi

# Step 3: Check if home-manager is available
if nix-channel --list | grep -q home-manager; then
    echo -e "${GREEN}home-manager channel is already added.${NC}"
else
    if confirm "Would you like to add the home-manager channel?"; then
        echo -e "${BLUE}Adding home-manager channel...${NC}"
        nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
        nix-channel --update
        echo -e "${GREEN}home-manager channel added successfully.${NC}"
    else
        echo -e "${YELLOW}Skipping home-manager channel setup.${NC}"
    fi
fi

# Step 4: Apply home-manager configuration
if confirm "Would you like to apply the home-manager configuration now?"; then
    echo -e "${BLUE}Applying home-manager configuration...${NC}"
    
    # Get the current username
    USERNAME=$(whoami)
    
    # Check if the username matches the one in the flake
    if [ "$USERNAME" != "thomasgl" ]; then
        echo -e "${YELLOW}Warning: Your username ($USERNAME) doesn't match the one in the flake configuration (thomasgl).${NC}"
        echo -e "${YELLOW}You may need to update the home-manager/linux.nix file to match your username.${NC}"
        
        if confirm "Would you like to continue anyway?"; then
            echo -e "${BLUE}Continuing with the configuration...${NC}"
        else
            echo -e "${RED}Aborting configuration application.${NC}"
            echo -e "${YELLOW}Please update the home-manager/linux.nix file with your username and home directory.${NC}"
            exit 1
        fi
    fi
    
    # Apply the configuration
    echo -e "${BLUE}Running home-manager switch...${NC}"
    nix run home-manager/release-24.11 -- switch --flake .#thomasgl
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}home-manager configuration applied successfully.${NC}"
    else
        echo -e "${RED}Failed to apply home-manager configuration.${NC}"
        echo -e "${YELLOW}Please check the error messages above.${NC}"
    fi
else
    echo -e "${YELLOW}Skipping home-manager configuration application.${NC}"
fi

echo
echo -e "${GREEN}Setup process completed!${NC}"
echo -e "${BLUE}You can now use your Nix configuration on this Linux system.${NC}"
echo -e "${YELLOW}If you need to update your configuration in the future, run:${NC}"
echo -e "${BLUE}nix run home-manager/release-24.11 -- switch --flake .#thomasgl${NC}"