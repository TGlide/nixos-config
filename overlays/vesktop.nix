final: prev: {
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];
    postFixup = ''
      ${oldAttrs.postFixup or ""}
      wrapProgram $out/bin/vesktop \
        # --add-flags "--enable-features=UseOzonePlatform" \
        # --add-flags "--enable-features=WaylandWindowDecorations" \
        # --add-flags "--ozone-platform=wayland" \
        # --add-flags "--disable-gpu"
    '';
  });
}
