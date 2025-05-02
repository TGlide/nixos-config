{
  pkgs,
  unstable,
  ...
}: {
  home.username = "thomasgl";
  home.homeDirectory = "/home/thomasgl";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # programming langs
    libgcc
    zap

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for 'ls'

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # productivity
    obsidian

    # dev tools
    vscode
    gimp
    inkscape
    sqlite
    unstable.ghostty

    # nix related
    nix-output-monitor
  ];

  programs.fish.functions = {
    modify_nix = ''
      cd ~/nixos-config/
      nvim
    '';
    rebuild_nix = ''
      home-manager switch --flake ~/nixos-config/
    '';
  };

  programs.ssh = {
    enable = true;
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
    '';
  };
}