{
  pkgs,
  commonPackages,
  commonShellHook,
  ...
}: let
  flutterPkg = pkgs.flutter.override {
    supportedTargetFlutterPlatforms = [
      "universal"
      "web"
      "android"
      "linux"
    ];
  };
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
    set(OPENSSL_SSL_LIBRARY "${pkgs.openssl.out}/lib/libssl.so" CACHE FILEPATH "OpenSSL SSL library" FORCE)
    set(CMAKE_PREFIX_PATH "${pkgs.openssl.out};${pkgs.openssl.dev};''${CMAKE_PREFIX_PATH}" CACHE STRING "CMake prefix path" FORCE)
    set(OPENSSL_CRYPTO_LIBRARY "${pkgs.openssl.out}/lib/libcrypto.so" CACHE FILEPATH "OpenSSL crypto library" FORCE)
  '';
in {
  linux = pkgs.mkShellNoCC {
    nativeBuildInputs =
      commonPackages
      ++ (with pkgs; [
        yq-go
        libsecret.dev
        openssl.dev
        clang
        openssl.out
        cmake
        pkg-config
      ])
      ++ [
        flutterPkg
      ];
    shellHook =
      ''
        export CMAKE_TOOLCHAIN_FILE="${cmakeToolchain}"
        export LD_LIBRARY_PATH="$PWD/eko_app/build/native_assets/linux:$LD_LIBRARY_PATH"
        export CHROME_EXECUTABLE=$(which chromium)
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
      ])
      ++ [
        flutterPkg
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
      ])
      ++ [
        flutterPkg
      ];
    shellHook =
      ''
        export CHROME_EXECUTABLE=$(which chromium)
      ''
      + commonShellHook;
  };
}
