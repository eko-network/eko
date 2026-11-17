{
  pkgs,
  lib,
  pname,
  gitRev ? "dirty",
  ...
}:
let
  # The openmls build hook downloads a prebuilt library from GitHub, which
  # can't happen in the sandbox. It prefers rust/target/release if present,
  # so build the bundled crate and drop it there.
  openmlsFrb = {
    version,
    src,
    ...
  }: let
    lib' = pkgs.rustPlatform.buildRustPackage {
      pname = "openmls_frb";
      inherit version;
      src = "${src}/rust";
      # Update when the openmls pub version changes.
      cargoHash = "sha256-yqlEKQK5ORU93FKZuvFW78m6VDTqfTCJlV28KGHcuew=";
      # Bundle sqlcipher and OpenSSL like upstream's prebuilt, so the
      # tarball doesn't depend on the host having libsqlcipher.
      dontCargoUseSystemLibs = true;
      nativeBuildInputs = [pkgs.perl];
      doCheck = false;
    };
  in
    pkgs.runCommand "pub-openmls-${version}" {inherit (src) passthru;} ''
      cp -r ${src} $out
      chmod -R +w $out
      install -Dm755 ${lib'}/lib/libopenmls_frb.so $out/rust/target/release/libopenmls_frb.so
    '';
in
pkgs.flutter.buildFlutterApplication {
  inherit pname;
  version = gitRev;
  src = lib.cleanSource ../eko_app;
  autoPubspecLock = ../eko_app/pubspec.lock;
  gitHashes = {
    ecp = "sha256-2GKWwUOyDwHGxO9qtM+0SBxRY4GIEUGw1CrLNghnxAQ=";
    webcrypto = "sha256-XkZe7LcVyUtUJoTqeyd87xLENJIIExgyI9lym/aQBtw=";
  };
  customSourceBuilders.openmls = openmlsFrb;
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
