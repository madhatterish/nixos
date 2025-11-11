{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, openssl
, ppp
, iptables
, procps
, jre
, gtk3
, glib
, libnotify
}:

stdenv.mkDerivation rec {
  pname = "netextender";
  version = "10.2.845";

  src = fetchurl {
    url = "https://software.sonicwall.com/NetExtender/NetExtender.Linux-${version}.x86_64.tgz";
    sha256 = "sha256-qmcG1pSm0ixCpTEHZBzBBEZDI4H0tsGcKX8ZXaTXDMk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    openssl
    gtk3
    glib
    libnotify
  ];

  # The tarball extracts to netExtenderClient/
  sourceRoot = "netExtenderClient";

  installPhase = ''
    runHook preInstall

    # Create directories
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/share/netextender
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/{16x16,32x32,48x48,128x128}/apps
    mkdir -p $out/share/man/man1

    # Install main binary
    install -Dm755 netExtender $out/bin/netextender

    # Install helper binaries
    install -Dm755 nxMonitor $out/bin/nxMonitor

    # Install libraries
    install -Dm755 libNetExtender.so $out/lib/libNetExtender.so
    install -Dm755 libNetExtenderEpc.so $out/lib/libNetExtenderEpc.so

    # Install support files
    install -Dm644 ca-bundle.crt $out/share/netextender/ca-bundle.crt
    install -Dm644 NetExtender.jar $out/share/netextender/NetExtender.jar
    install -Dm644 README $out/share/netextender/README

    # Install GUI wrapper
    install -Dm755 netExtenderGui $out/bin/netextender-gui

    # Install desktop file
    install -Dm644 NetExtender.desktop $out/share/applications/netextender.desktop

    # Install icons
    install -Dm644 icons/nx16.png $out/share/icons/hicolor/16x16/apps/netextender.png
    install -Dm644 icons/nx32.png $out/share/icons/hicolor/32x32/apps/netextender.png
    install -Dm644 icons/nx48.png $out/share/icons/hicolor/48x48/apps/netextender.png
    install -Dm644 icons/nx128.png $out/share/icons/hicolor/128x128/apps/netextender.png

    # Install man page
    install -Dm644 netExtender.1 $out/share/man/man1/netextender.1

    # Wrap binaries with necessary paths and environment
    wrapProgram $out/bin/netextender \
      --prefix PATH : ${lib.makeBinPath [ ppp iptables procps ]} \
      --prefix LD_LIBRARY_PATH : $out/lib \
      --set NETEXTENDER_DATADIR $out/share/netextender

    wrapProgram $out/bin/netextender-gui \
      --prefix PATH : ${lib.makeBinPath [ jre ppp iptables procps ]}:$out/bin \
      --prefix LD_LIBRARY_PATH : $out/lib \
      --set NETEXTENDER_DATADIR $out/share/netextender

    # Fix desktop file paths
    substituteInPlace $out/share/applications/netextender.desktop \
      --replace-fail "/usr/bin/netExtenderGui" "$out/bin/netextender-gui" \
      --replace-fail "/usr/share/icons" "$out/share/icons"

    runHook postInstall
  '';

  meta = with lib; {
    description = "SonicWall NetExtender VPN Client";
    longDescription = ''
      SonicWall NetExtender is a SSL VPN client that provides secure remote access.
      Note: This requires root privileges for network configuration.
    '';
    homepage = "https://www.sonicwall.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
