{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    neofetch
    nnn # terminal file manager

    # dev tools
    neovim
    alejandra
    lazygit
    chezmoi

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

    # fun
    spotify-player
    vesktop
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Thomas G. Lopes";
    # userEmail = "thomasgl@pm.me";
    userEmail = "26071571+TGlide@users.noreply.github.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      credential.helper = "${
        pkgs.git.override {withLibsecret = true;}
      }/bin/git-credential-libsecret";
    };
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
          set fish_greeting # Disable greeting
          export NIX_LD=$(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD ')
      neofetch
    '';
    plugins = [
      # Manually packaging and enable a plugin
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }
    ];
    shellAliases = {
      nv = "nvim";
      che = "chezmoi";
    };
    functions = {
      modify_nixos = ''
        cd /etc/nixos
        sudo chown -R thomasgl /etc/nixos
        nvim /etc/nixos
        sudo chown -R root /etc/nixos
      '';
      bw-unlock = ''set -Ux BW_SESSION (bw unlock --raw || echo "Error unlocking BW")'';
      bw-create-note = ''
        function bw-create-note --argument-names 'content_or_name' 'name'
            if isatty stdin
                # Direct input mode
                set notes_content $content_or_name
                set note_name $name
            else
                # Pipe mode
                read -z notes_content
                set note_name $content_or_name
            end

            # If no name provided, use default
            if test -z "$note_name"
                set note_name "secure-note"
            end

            # If no content, show usage
            if test -z "$notes_content"
                echo "Usage: bw-create-note 'content' 'note name'"
                echo "Or: command | bw-create-note 'note name'"
                return 1
            end

            bw get template item | jq --arg folderId (bw list folders | jq -r '.[] | select(.name == "chezmoi") | .id') \
                --arg notes "$notes_content" \
                --arg name "$note_name" \
                '.type = 2 | .secureNote.type = 0 | .notes=$notes | .name = $name | .folderId=$folderId' | \
                bw encode | bw create item
        end
      '';
    };
  };

  programs.kitty = lib.mkForce {
    enable = true;
    themeFile = "Catppuccin-Macchiato";
    settings = {
      tab_bar_min_tabs = 1;
      tab_bar_edge = "bottom";
      # tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      tab_bar_margin_width = "0.0";
      tab_bar_margin_height = "0.0 0.0";
      tab_bar_style = "powerline";
      tab_bar_align = "left";
      tab_separator = "";
      tab_activity_sybol = "none";
      tab_title_template = "{index}  {tab.active_wd.rsplit('/', 1)[-1]}";
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
