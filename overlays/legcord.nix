final: prev: {
  legcord = prev.legcord.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];
    postFixup = ''
      ${oldAttrs.postFixup or ""}
      wrapProgram $out/bin/legcord \
        --add-flags "--enable-features=UseOzonePlatform,VaapiVideoDecoder" \
        --add-flags "--enable-features=WaylandWindowDecorations" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--use-angle=vulkan" \
    '';
  });
}
