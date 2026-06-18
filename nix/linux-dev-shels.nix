{
  pkgs,
  commonPackages,
  commonShellHook,
  ...
}: let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = ["35.0.0"];
    platformVersions = [36 35 34 33 31];
    includeNDK = true;
    ndkVersions = ["28.2.13676358" "27.0.12077973"];
    includeCmake = true;
    cmakeVersions = ["3.22.1"];
  };
  androidSdk = androidComposition.androidsdk;
  sdkPath = "${androidSdk}/libexec/android-sdk";
  cmakeToolchain = pkgs.writeText "nix-toolchain.cmake" ''
    set(OPENSSL_USE_STATIC_LIBS OFF CACHE BOOL "Use shared OpenSSL libs on Nix" FORCE)
    set(OPENSSL_SSL_LIBRARY "${pkgs.openssl.out}/lib/libssl.so" CACHE FILEPATH "OpenSSL SSL library" FORCE)
    set(OPENSSL_CRYPTO_LIBRARY "${pkgs.openssl.out}/lib/libcrypto.so" CACHE FILEPATH "OpenSSL crypto library" FORCE)
    set(CMAKE_PREFIX_PATH "${pkgs.openssl.dev};${pkgs.openssl.out};''${CMAKE_PREFIX_PATH}" CACHE STRING "CMake prefix path" FORCE)
  '';
in {
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
