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
    ecp = "sha256-uorxo4mhlESmJmrfFZWavxVv2nGYoWnTn74DTf8bds4=";
    webcrypto = "sha256-XkZe7LcVyUtUJoTqeyd87xLENJIIExgyI9lym/aQBtw=";
  };
  customSourceBuilders.sqlcipher_flutter_libs = {
    version,
    src,
    ...
  }: let
    sqlcipherAmalgamation = pkgs.fetchurl {
      url = "https://fsn1.your-objectstorage.com/simon-public/assets/sqlcipher/v4_10_0.c";
      hash = "sha256-3njvCHy8Juj+WE3gXxeQ8+NIl9uHMegVTcZ00/LfKMs=";
    };
  in
    pkgs.stdenv.mkDerivation {
      pname = "sqlcipher_flutter_libs";
      inherit version src;
      inherit (src) passthru;
      dontConfigure = true;
      dontBuild = true;
      postPatch = ''
        substituteInPlace linux/CMakeLists.txt \
          --replace-fail 'statically" ON)' 'statically" OFF)' \
          --replace-fail '${sqlcipherAmalgamation.url}' 'file://${sqlcipherAmalgamation}'
      '';
      installPhase = "cp -r . $out";
    };
  customSourceBuilders.openmls = {
    version,
    src,
    ...
  }: let
    openmlsFrb = pkgs.fetchurl {
      url = "https://github.com/djx-y-z/openmls_dart/releases/download/openmls_frb-1.4.0/openmls_frb-1.4.0-linux-x86_64.tar.gz";
      hash = "sha256-Jl69ix6pCAoB+gsRrQl68GUnc76PmqJRir+4HDMRTek=";
    };
  in
    pkgs.stdenv.mkDerivation {
      pname = "openmls";
      inherit version src;
      inherit (src) passthru;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        cp -r . $out
        mkdir -p $out/rust/target/release
        tar -xzf ${openmlsFrb} -C $out/rust/target/release libopenmls_frb.so
      '';
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
    for lib in libwebcrypto.so libopenmls_frb.so; do
      if [ -f "build/native_assets/linux/$lib" ]; then
        install -Dm755 "build/native_assets/linux/$lib" "$out/app/${pname}/lib/$lib"
      else
        echo "$lib not found at build/native_assets/linux" >&2
        exit 1
      fi
    done
  '';

  meta = {
    platforms = lib.platforms.linux;
    mainProgram = pname;
    license = pkgs.lib.licenses.agpl3Only;
  };
}
