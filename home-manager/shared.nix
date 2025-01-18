{pkgs, ...}: {
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

    # terminal tools
    nerdfetch
    ripgrep

    # LSPs
    lua-language-server
    typescript
    typescript-language-server
    svelte-language-server
    tailwindcss
    # tailwindcss-language-server
    nixd
    stylua

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
      test -f ~/.config/myvars; and source ~/.config/myvars
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
