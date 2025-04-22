{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "playdate-mirror";
  version = "1.0.0"; # You might want to extract this from the .deb filename or metadata if possible

  src = ./playdate-mirror.deb;

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];

  buildInputs = with pkgs; [
    # Common dependencies for GUI apps, USB, audio
    glibc
    libusb1
    SDL2
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    alsa-lib
    udev
    gtk3
    pango
    cairo
    gdk-pixbuf
    webkitgtk
    libpulseaudio
    # Add more dependencies here if autoPatchelfHook reports missing ones
  ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    # Create necessary directories in the output path
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/scalable/apps
    mkdir -p $out/lib/udev/rules.d

    # Move the executable
    if [ -f $out/usr/bin/mirror ]; then
      mv $out/usr/bin/mirror $out/bin/
    else
      echo "Executable not found at $out/usr/bin/mirror"
      exit 1
    fi

    # Install .desktop file
    if [ -f $out/usr/share/applications/date.play.mirror.desktop ]; then
      mv $out/usr/share/applications/date.play.mirror.desktop $out/share/applications/
    else
      echo "Desktop file not found at $out/usr/share/applications/date.play.mirror.desktop"
      # Optionally exit 1 here if the desktop file is critical
    fi

    # Install icon file
    if [ -f $out/usr/share/icons/hicolor/scalable/apps/date.play.mirror.svg ]; then
      mv $out/usr/share/icons/hicolor/scalable/apps/date.play.mirror.svg $out/share/icons/hicolor/scalable/apps/
    else
      echo "Icon file not found at $out/usr/share/icons/hicolor/scalable/apps/date.play.mirror.svg"
      # Optionally exit 1 here if the icon file is critical
    fi

    # Install udev rules
    if [ -f $out/etc/udev/rules.d/50-playdate-mirror.rules ]; then
      mv $out/etc/udev/rules.d/50-playdate-mirror.rules $out/lib/udev/rules.d/
    else
      echo "Udev rules not found at $out/etc/udev/rules.d/50-playdate-mirror.rules"
      # Optionally exit 1 here if udev rules are critical
    fi

    # Clean up the unpacked directories now that we've moved the necessary files
    rm -rf $out/usr $out/etc
  '';
  postFixup = ''
    # Set standard permissions
    find $out -type d -exec chmod 755 {} \;
    find $out -type f -exec chmod 644 {} \;
    # Ensure the main executable has execute permissions
    chmod 755 $out/bin/mirror

    # Wrap the executable to set SDL audio driver
    wrapProgram $out/bin/mirror \
      --set SDL_AUDIODRIVER pulseaudio \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libpulseaudio ]}"
  '';


  meta = with pkgs.lib; {
    description = "Playdate Mirror application";
    homepage = "https://play.date/"; # Replace with actual homepage if known
    license = licenses.unfree; # Assuming it's unfree, change if needed
    platforms = platforms.linux; # Specify supported platforms
    maintainers = [ maintainers.your_github_username ]; # Replace with your username
  };
}