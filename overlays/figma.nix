final: prev: {
  figma-linux = prev.figma-linux.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];
    postFixup = ''
      ${oldAttrs.postFixup or ""}
      wrapProgram $out/bin/figma-linux \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform=wayland"
    '';
  });
}
