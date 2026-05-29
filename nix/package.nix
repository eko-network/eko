{
  pkgs,
  lib,
  pname,
  gitRev ? "dirty",
  ...
}:
pkgs.flutter.buildFlutterApplication {
  inherit pname;
  version = gitRev;
  src = lib.cleanSource ../eko_app;
  autoPubspecLock = ../eko_app/pubspec.lock;
  gitHashes = {
    webcrypto = "sha256-XkZe7LcVyUtUJoTqeyd87xLENJIIExgyI9lym/aQBtw=";
  };
  vendorHash = lib.fakeHash;
  dontUseCmakeConfigure = true;

  buildInputs = with pkgs; [
    gtk3
    glib
    jsoncpp
    openssl
    libsecret
    sqlite
  ];

  nativeBuildInputs = with pkgs; [
    copyDesktopItems
    wrapGAppsHook3
    pkg-config
    cmake
    jq
    yq-go
  ];

  preBuild = builtins.readFile ./prebuild.sh;

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : "$out/app/${pname}/lib" \
    --set FONTCONFIG_FILE ${pkgs.fontconfig.out}/etc/fonts/fonts.conf \
    --set LOCALE_ARCHIVE ${pkgs.glibcLocales}/lib/locale/locale-archive
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "com.eko.network";
      desktopName = "eko";
      comment = "eko social network";
      exec = pname;
      icon = pname;
      categories = ["Network"];
    })
  ];

  postInstall = ''
    install -Dm644 "$src/linux/assets/logo.svg" "$out/share/icons/hicolor/scalable/apps/${pname}.svg"
    if [ -f "build/native_assets/linux/libwebcrypto.so" ]; then
      install -Dm755 "build/native_assets/linux/libwebcrypto.so" "$out/app/${pname}/lib/libwebcrypto.so"
    else
      echo "libwebcrypto.so not found at build/native_assets/linux" >&2
      exit 1
    fi
  '';

  meta = {
    platforms = lib.platforms.linux;
    mainProgram = pname;
    license = pkgs.lib.licenses.agpl3Only;
  };
}
