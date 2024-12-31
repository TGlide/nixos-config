final: prev: {
  spotify = prev.spotify.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];
    postFixup = ''
      ${oldAttrs.postFixup or ""}
      wrapProgram $out/bin/spotify \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform=wayland"
    '';
  });
}
