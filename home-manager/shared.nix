{
  pkgs,
  unstable,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  home.packages = with pkgs; [
    neofetch
    nnn # terminal file manager

    # secrets
    rbw

    # dev tools
    neovim
    alejandra
    lazygit
    chezmoi
    kitty
    wezterm
    unstable.bun
    nodejs_22
    pnpm
    yarn
    # unstable.ghostty

    # terminal tools
    nerdfetch
    ripgrep
    eza
    autojump
    fzf # A command-line fuzzy finder
    tokei
    tldr

    # LSPs
    lua-language-server
    typescript
    typescript-language-server
    unstable.svelte-language-server
    tailwindcss
    unstable.tailwindcss-language-server
    nixd
    stylua

    # (
    #   callPackage
    #   ../packages/tailwind-language-server.nix
    #   {
    #     pnpm = pnpm_9;
    #     fetchFromGitHub = fetchFromGitHub;
    #     nodejs = nodejs;
    #   }
    # )
    (callPackage ../packages/goose.nix {})
    (callPackage ../packages/claude-code {})

    # fun
    spotify-player
    # spotify
    # spicetify-cli
    vesktop
    protonup
    protonup-qt
    slack
  ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      # https://github.com/Gerg-L/spicetify-nix/blob/master/docs/EXTENSIONS.md
      # adblockify
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
      keyboardShortcut
      popupLyrics
      skipStats
    ];
    # https://github.com/Gerg-L/spicetify-nix/blob/master/docs/THEMES.md
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "macchiato";
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Thomas G. Lopes";
    # userEmail = "thomasgl@pm.me";
    userEmail = "26071571+TGlide@users.noreply.github.com";
    extraConfig = {
      pull.rebase = true;
      init = {
        defaultBranch = "main";
      };
      credential.helper = "${
        pkgs.git.override {withLibsecret = true;}
      }/bin/git-credential-libsecret";
    };
    lfs.enable = true;
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
      test -f ~/.config/myvars; and source ~/.config/myvars
      test -f /run/current-system/sw/share/autojump/autojump.fish; and source /run/current-system/sw/share/autojump/autojump.fish
      nerdfetch
    '';
    plugins = [
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf.src;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
    ];
    shellAliases = {
      nv = "nvim";
      che = "chezmoi";
      gcho = "git checkout";
      gchm = "git checkout main";
      gchd = "git checkout develop";
      gs = "git status";
      gp = "git push";
      gpuoh = "git push --set-upstream origin HEAD";
      gl = "git pull";
      gcnv = "git commit --no-verify";
      gca = "git commit --amend";
      gb = "git branch";
      gr = "git remote";
      grv = "git remote -v";
      grr = "git remote remove";
      gra = "git remote add";
      gm = "git merge";
      gd = "git diff";
      gdc = "git diff --cached";
      gdt = "git diff-tree --no-commit-id --name-only -r";
      gf = "git fetch";
      ngoose = "nix-shell -p uv --run 'goose session'";
    };
    functions = {
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
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        	yazi $argv --cwd-file="$tmp"
        	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        		builtin cd -- "$cwd"
        	end
        	rm -f -- "$tmp"
      '';
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
