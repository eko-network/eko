{
  description = "Flutter";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        system,
        pkgs,
        ...
      }: let
        pname = "eko";
        gitRev = inputs.self.shortRev or inputs.self.dirtyShortRev or "dirty";
        mkGenericRelease = import ./nix/mk-generic.nix {inherit pkgs;};
        ekoApp = pkgs.callPackage ./nix/package.nix {
          inherit gitRev;
          inherit pname;
        };
        commonPackages = with pkgs; [
          gcc
          jdk
          ninja
          unzip
          supabase-cli
          sops
          age
        ];
        commonShellHook = ''
          git config core.hooksPath scripts/git-hooks
        '';
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        packages = {
          default = ekoApp;
          tarball = mkGenericRelease {
            inherit pname;
            app = ekoApp;
            version = gitRev;
          };
        };
        devShells.default =
          if pkgs.stdenv.isDarwin
          then let
            flutterPkg = pkgs.flutter.override {
              supportedTargetFlutterPlatforms = [
                "universal"
                "web"
                "macos"
                "ios"
              ];
            };
          in
            pkgs.mkShellNoCC {
              nativeBuildInputs = commonPackages ++ [flutterPkg];
              shellHook =
                ''
                                    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
                                    export PATH=/usr/bin:/bin:/usr/sbin:/sbin:$PATH
                                    unset CC CXX LD AR NM RANLIB STRIP SDKROOT CPATH LIBRARY_PATH CFLAGS CXXFLAGS LDFLAGS OBJCFLAGS OBJCXXFLAGS
                                    export FLUTTER_ROOT_LOCAL="$HOME/.cache/flutter-sdk-nix-${pkgs.flutter.version}"
                                    if [ ! -x "$FLUTTER_ROOT_LOCAL/bin/flutter" ]; then
                                      mkdir -p "$FLUTTER_ROOT_LOCAL"
                                      /usr/bin/rsync -aL --delete --chmod=Du+rwx,Dgo+rx,Fu+rwX,Fgo+rX "${flutterPkg}/" "$FLUTTER_ROOT_LOCAL/"
                                    fi
                                    chmod -R u+w "$FLUTTER_ROOT_LOCAL" 2>/dev/null || true
                                    export FLUTTER_ROOT="$FLUTTER_ROOT_LOCAL"
                                    export PATH="$FLUTTER_ROOT/bin:$PATH"
                                    if [ -x "$FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart" ]; then
                                      cat > "$FLUTTER_ROOT/bin/dart" <<'EOF'
                  #!/bin/sh
                  exec "$(dirname "$0")/cache/dart-sdk/bin/dart" "$@"
                  EOF
                                      chmod +x "$FLUTTER_ROOT/bin/dart"
                                    fi
                ''
                + commonShellHook;
            }
          else let
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
          in
            pkgs.mkShellNoCC {
              ANDROID_SDK_ROOT = sdkPath;
              ANDROID_HOME = sdkPath;
              nativeBuildInputs =
                commonPackages
                ++ (with pkgs; [
                  ungoogled-chromium
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
                  androidSdk
                ];
              shellHook =
                ''
                  export CMAKE_TOOLCHAIN_FILE="${cmakeToolchain}"
                  export LD_LIBRARY_PATH="$PWD/eko_app/build/native_assets/linux:$LD_LIBRARY_PATH"
                  export CHROME_EXECUTABLE=$(which chromium)
                ''
                + commonShellHook;
            };
      };
    };
}
