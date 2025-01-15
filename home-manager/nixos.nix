{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.username = "thomasgl";
  home.homeDirectory = "/home/thomasgl";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # programming langs
    libgcc

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

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
    cowsay
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

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
  ];

  imports = [
    inputs.textfox.homeManagerModules.default
  ];

  textfox = {
    enable = true;
    profile = "textfox profile";
    config = {
      # Optional config
    };
  };

  programs.fish.functions = {
    modify_ags = ''
      cd /etc/nixos/ags
      sudo chown -R thomasgl /etc/nixos/ags
      nvim /etc/nixos/ags
      sudo chown -R root /etc/nixos/ags
    '';
    modify_nixos = ''
      cd /etc/nixos
      sudo chown -R thomasgl /etc/nixos
      nvim /etc/nixos
      sudo chown -R root /etc/nixos
    '';
  };
}
