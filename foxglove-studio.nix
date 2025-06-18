{
  stdenv,
  lib,
  system,
  fetchurl,
  dpkg,
  glibc,
  gcc-unwrapped,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  x11basic,
  gtk3,
  pango,
  cairo,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  expat,
  libxcb,
  libxkbcommon,
  udev,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  dbus,
  atk,
  cups,
  libdrm,
  nspr,
  nss,
  mesa,
  ...
}:
let
  version = "2.29.0";

  src = fetchurl {
      url = "https://get.foxglove.dev/desktop/v${version}/foxglove-studio-${version}-linux-amd64.deb";
      hash = "sha256-sD0QlTRJ/9vd4YXIXqNuL7vLOYoLf8j9O7dzLzvwfgw=";
    };
in
stdenv.mkDerivation {
  name = "foxglove-studio";
  inherit src system;
  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    copyDesktopItems
  ];

  # Required at running time
  buildInputs = [
    glibc
    gcc-unwrapped
    x11basic
    gtk3
    pango
    cairo
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    expat
    libxcb
    libxkbcommon
    udev
    alsa-lib
    at-spi2-atk
    at-spi2-core
    dbus
    atk
    cups
    libdrm
    nspr
    nss
    mesa
  ];

  # # Required at running time
  # buildInputs = [

  # ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    # Create necessary directories
    mkdir -p $out/{bin,opt,share}
    pwd
    ls -R
    # Copy main application files - handle space in directory name
    cp -r "opt/Foxglove" "$out/opt/"

    # Copy desktop integration files
    cp -r usr/share/applications $out/share/
    cp -r usr/share/icons $out/share/
    cp -r usr/share/mime $out/share/
    cp -r usr/share/doc $out/share/

    # Create symlink in bin directory
    ln -s "$out/opt/Foxglove/foxglove-studio" $out/bin/foxglove-studio

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "foxglove-studio";
      exec = "foxglove-studio";
      icon = "foxglove-studio";
      genericName = "Foxglove Studio";
      desktopName = "Foxglove Studio";
    })
  ];

  meta = with lib; {
    description = "Foxglove studio";
    homepage = "https://foxglove.dev/";
    license = licenses.mpl20;
    # maintainers = with lib.maintainers; [ jerry8137 ];
    platforms = [ "x86_64-linux" ];
  };
}