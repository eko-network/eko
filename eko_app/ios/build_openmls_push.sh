#!/usr/bin/env bash
# Builds OpenmlsPush.xcframework, the C API MessengerNotificationService
# decrypts with, from the openmls package `flutter pub get` resolved, so the
# extension reads mls.db with the very engine the app writes it with. Needs
# Rust with the iOS targets:
#   rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
set -euo pipefail
cd "$(dirname "$0")"

root=$(python3 - <<'PY'
import json, pathlib, urllib.parse, urllib.request
config = pathlib.Path("../.dart_tool/package_config.json").resolve()
package = next(p for p in json.loads(config.read_text())["packages"] if p["name"] == "openmls")
uri = urllib.parse.urljoin(config.as_uri(), package["rootUri"])
print(urllib.request.url2pathname(urllib.parse.urlparse(uri).path))
PY
)
echo "Building OpenmlsPush.xcframework from $root"

# Nix shells point SDKROOT at a macOS SDK, see README.md
env -u SDKROOT make -C "$root" push-xcframework
rm -rf OpenmlsPush.xcframework
cp -R "$root/push_ffi/target/OpenmlsPush.xcframework" .
