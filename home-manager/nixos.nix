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
    # productivity
    obsidian

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
  ];

  imports = [inputs.textfox.homeManagerModules.default];

  textfox = {
    enable = true;
    profile = "textfox profile";
    config = {
      # Optional config
    };
  };
}
