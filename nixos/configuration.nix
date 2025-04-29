# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  unstable,
  ...
}: let
  pkgs-unstable-hypr = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.kolide-launcher.nixosModules.kolide-launcher
  ];

  # assertions = [
  #   {
  #     assertion = false;
  #     message = "Available attributes: ${toString (builtins.attrNames inputs.kolide-launcher.nixosModules)}";
  #   }
  # ];

  # Bootloader
  boot.loader = {
    timeout = 30;
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6C0B-277F";
    fsType = "vfat";
    options = ["defaults"];
  };

  powerManagement.enable = false;

  # Disable sleep
  systemd = {
    targets = {
      sleep = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
      suspend = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
      hibernate = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
      "hybrid-sleep" = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
    };
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    services = {
      systemd-udevd.restartIfChanged = false;
      # NetworkManager-wait-online.enable = lib.mkForce false;
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
    LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
  };

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # hardware.opengl = {
  #   package = pkgs-unstable-hypr.mesa.drivers;
  #
  #   # if you also want 32-bit support (e.g for Steam)
  #   driSupport32Bit = true;
  #   package32 = pkgs-unstable-hypr.pkgsi686Linux.mesa.drivers;
  # };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta; # NixOS Stable
    # package = unstable.linuxPackages.nvidiaPackages.production; # NixOS unstable

    nvidiaPersistenced = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thomasgl = {
    isNormalUser = true;
    description = "Thomas G. Lopes";
    extraGroups = ["networkmanager" "wheel" "docker"];
    # packages = with pkgs; [
    #   #  thunderbird
    # ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession = {
      enable = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  security.polkit.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (import ../scripts {inherit pkgs;})

    # general
    gparted
    blueman
    vial
    via
    inxi
    fd
    bitwarden-desktop
    bitwarden-cli
    efibootmgr
    obs-studio
    mpv
    figma-linux
    steam-tui
    xmousepasteblock
    inputs.zen-browser.packages."${pkgs.system}".default
    pkgs.firefoxpwa

    # terminal utils
    gtop
    entr
    wget
    pciutils
    fontpreview
    # autojump
    killall
    notify-desktop
    ffmpeg
    ngrok
    unstable.yazi

    # developer tools
    gh
    git
    vim
    inputs.helix.packages."${pkgs.system}".helix
    gcc
    clang
    cargo
    alacritty
    wl-clipboard
    aider-chat
    prefetch-npm-deps
    sl
    brotli
    sd
    colima
    unstable.lmstudio
    # unstable.open-webui
    # unstable.ollama-cuda # damn this takes some time to build
    chromium
    cargo
    dive
    podman-tui
    docker-compose
    podman-compose
    nvidia-container-toolkit

    # ricing
    cbonsai
    cmatrix
    tty-clock
    pipes-rs

    # hyprland extras
    wofi
    wofi-emoji
    waybar
    hyprpaper
    hyprlock
    hypridle
    hyprshot
    font-awesome
    pavucontrol
    # swaynotificationcenter
    playerctl
    pipewire
    joystickwake

    # general
    smplayer
  ];
  # programs.nix-ld.enable = true;

  nixpkgs.config.chromium = {
    # enablePepperFlash = true;
    enableWideVine = true;
    commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    # docker = {
    #   enable = true;
    #   rootless = {
    #     enable = true;
    #     setSocketVariable = true;
    #   };
    #   package = pkgs.docker_27;
    # };
  };

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerdfonts
    cozette
  ];

  environment.variables.EDITOR = "vim";

  age.identityPaths = ["/home/thomasgl/.ssh/id_ed25519"];

  age.secrets.kolide = {
    file = ../secrets/kolide.age;
    # Make it accessible to the appropriate service user
    owner = "root";
    group = "root";
    mode = "0400";
  };
  environment.etc."kolide-k2/secret" = {
    mode = "0600";
    source = config.age.secrets.kolide.path;
  };

  services.kolide-launcher.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--accept-dns" # Also accept DNS configuration if needed
    ];
  };

  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [pkgs.via];
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    KERNEL=="ttyACM[0-9]*",MODE="0666"
  '';

  programs.ssh = {
    startAgent = true;
    # Optional: Add specific host configurations
    extraConfig = ''
      Host vps
      	HostName 37.221.194.92
      	User root
      	IdentityFile ~/.ssh/vps

      Host github.com
      	HostName github.com
      	User git
      	IdentityFile ~/.ssh/github
      	AddKeysToAgent yes


      Host runpod
      	HostName ssh.runpod.io
      	User x5d6g6areohzyh-64410d73
      	IdentityFile ~/.ssh/runpod
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      53317
      9090
    ];
    allowedUDPPorts = [
      53317
      54982
    ];
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  boot.supportedFilesystems = ["ntfs"];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
}
