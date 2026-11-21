{
  pkgs,
  commonPackages,
  commonShellHook,
  ...
}: let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = ["36.0.0" "35.0.0"];
    platformVersions = ["37.0" 36 35 34 33 31];
    includeNDK = true;
    ndkVersions = ["28.2.13676358" "27.0.12077973"];
    includeCmake = true;
    cmakeVersions = ["3.22.1"];
  };
  androidSdk = androidComposition.androidsdk;
  sdkPath = "${androidSdk}/libexec/android-sdk";
  # A separate SDK for the emulator, so the build SDK above doesn't pull a
  # system image for every platform it targets
  emulatorAbi =
    if pkgs.stdenv.hostPlatform.isAarch64
    then "arm64-v8a"
    else "x86_64";
  emulatorSdk =
    (pkgs.androidenv.composeAndroidPackages {
      platformVersions = [36];
      buildToolsVersions = ["35.0.0"];
      includeCmake = false;
      includeEmulator = true;
      includeSystemImages = true;
      systemImageTypes = ["google_apis"];
      abiVersions = [emulatorAbi];
    }).androidsdk;
  emulatorSdkPath = "${emulatorSdk}/libexec/android-sdk";
  # Creates the AVD on first use, then boots it. Extra args go to `emulator`,
  # e.g. `eko-emulator -wipe-data`
  ekoEmulator = pkgs.writeShellScriptBin "eko-emulator" ''
    set -euo pipefail
    export ANDROID_SDK_ROOT="${emulatorSdkPath}" ANDROID_HOME="${emulatorSdkPath}"
    avd=eko-api36
    if ! ${emulatorSdk}/bin/avdmanager list avd -c | grep -qx "$avd"; then
      echo no | ${emulatorSdk}/bin/avdmanager create avd --force -n "$avd" -d pixel_7 \
        -k "system-images;android-36;google_apis;${emulatorAbi}"
      echo "hw.keyboard=yes" >>"''${ANDROID_AVD_HOME:-$HOME/.android/avd}/$avd.avd/config.ini"
    fi
    # the host GPU renderer crashes (SIGILL in gfxstream) once Flutter draws
    exec ${emulatorSdk}/bin/emulator -avd "$avd" -gpu swiftshader_indirect "$@"
  '';
  cmakeToolchain = pkgs.writeText "nix-toolchain.cmake" ''
    set(OPENSSL_USE_STATIC_LIBS OFF CACHE BOOL "Use shared OpenSSL libs on Nix" FORCE)
    set(OPENSSL_SSL_LIBRARY "${pkgs.openssl.out}/lib/libssl.so" CACHE FILEPATH "OpenSSL SSL library" FORCE)
    set(OPENSSL_CRYPTO_LIBRARY "${pkgs.openssl.out}/lib/libcrypto.so" CACHE FILEPATH "OpenSSL crypto library" FORCE)
    set(CMAKE_PREFIX_PATH "${pkgs.openssl.dev};${pkgs.openssl.out};''${CMAKE_PREFIX_PATH}" CACHE STRING "CMake prefix path" FORCE)
  '';
in rec {
  linux = pkgs.mkShellNoCC {
    nativeBuildInputs =
      commonPackages
      ++ (with pkgs; [
        yq-go
        libsecret.dev
        clang
        openssl.dev
        openssl.out
        cmake
        flutter
        cmake
        dart
        pkg-config
      ]);
    shellHook = ''
      export CMAKE_TOOLCHAIN_FILE="${cmakeToolchain}"
      # The Linux app links this nixpkgs' glibc, the host's mesa may need a newer
      # one. run_dev.sh / scripts/dev.sh point EGL at a mesa from this nixpkgs.
      export EKO_GL_MESA="${pkgs.mesa}"
      export EKO_GL_LIBGLVND="${pkgs.libglvnd}"
    ''
    + commonShellHook;
  };
  android = pkgs.mkShellNoCC {
    ANDROID_SDK_ROOT = sdkPath;
    ANDROID_HOME = sdkPath;
    nativeBuildInputs =
      commonPackages
      ++ (with pkgs; [
        clang
        cmake
        flutter
        dart
      ])
      ++ [
        androidSdk
      ];
    shellHook =
      commonShellHook;
  };
  android-emulator = android.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ekoEmulator];
  });
  web = pkgs.mkShellNoCC {
    nativeBuildInputs =
      commonPackages
      ++ (with pkgs; [
        ungoogled-chromium
        flutter
        dart
      ]);
    shellHook =
      ''
        export CHROME_EXECUTABLE=$(which chromium)
      ''
      + commonShellHook;
  };
}
