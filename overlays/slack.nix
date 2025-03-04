final: prev: {
  slack = prev.slack.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];
    postFixup = ''
      ${oldAttrs.postFixup or ""}
      wrapProgram $out/bin/slack \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform=wayland"
    '';
  });
}
