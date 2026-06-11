{
  pkgs,
  commonShellHook,
  commonPackages,
}: let
  flutterPkg = pkgs.flutter.override {
    supportedTargetFlutterPlatforms = [
      "universal"
      "web"
      "macos"
      "ios"
    ];
  };
in {
  darwin = pkgs.mkShellNoCC {
    nativeBuildInputs = commonPackages ++ [flutterPkg];
    shellHook =
      ''
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
        export PATH=/usr/bin:/bin:/usr/sbin:/sbin:$PATH
        unset CC CXX LD AR NM RANLIB STRIP SDKROOT CPATH LIBRARY_PATH CFLAGS CXXFLAGS LDFLAGS OBJCFLAGS OBJCXXFLAGS
        export FLUTTER_ROOT_LOCAL="$HOME/.cache/flutter-sdk-nix-${pkgs.flutter.version}"
        if [ ! -x "$FLUTTER_ROOT_LOCAL/bin/flutter" ] || [ ! -f "$FLUTTER_ROOT_LOCAL/.nix-store-path" ] || [ "$(cat "$FLUTTER_ROOT_LOCAL/.nix-store-path" 2>/dev/null)" != "${flutterPkg}" ]; then
          mkdir -p "$FLUTTER_ROOT_LOCAL"
          /usr/bin/rsync -aL --delete --chmod=Du+rwx,Dgo+rx,Fu+rwX,Fgo+rX "${flutterPkg}/" "$FLUTTER_ROOT_LOCAL/"
          echo "${flutterPkg}" > "$FLUTTER_ROOT_LOCAL/.nix-store-path"
        fi
        chmod -R u+w "$FLUTTER_ROOT_LOCAL/bin/cache/artifacts/engine" 2>/dev/null || true
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
  };
}
