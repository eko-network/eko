#!/usr/bin/env bash
set -e

yq -i '.flutter.fonts += [{"family":"Inter","fonts":[{"asset":"fonts/linux/Inter-Cleaned.ttf"},{"asset":"fonts/linux/Inter-Italic-Cleaned.ttf"}]},{"family":"NotoEmoji","fonts":[{"asset":"fonts/linux/NotoColorEmoji.ttf"}]}]' pubspec.yaml

webcrypto_root_uri="$(jq -r '.packages[] | select(.name=="webcrypto") | .rootUri' .dart_tool/package_config.json)"
if [ -z "$webcrypto_root_uri" ] || [ "$webcrypto_root_uri" = "null" ]; then
  echo "webcrypto package not found in package_config.json" >&2
  exit 1
fi

webcrypto_root="${webcrypto_root_uri#file://}"
cmake -S "$webcrypto_root/src" -B .dart_tool/webcrypto
cmake --build .dart_tool/webcrypto --target webcrypto
