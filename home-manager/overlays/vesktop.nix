final: prev: {
  vesktop = prev.vesktop.override {
    commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
  };
}
