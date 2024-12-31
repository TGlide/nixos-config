final: prev: {
  vesktop = prev.vesktop.override {
    commandLinesArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
  };
}
