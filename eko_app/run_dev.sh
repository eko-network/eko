#!/usr/bin/env bash

FLUTTER_COMMAND="flutter run \
  --dart-define=USE_LOCAL=1 \
  --dart-define=SUPABASE_URL=\"$SUPABASE_URL\" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=\"$SUPABASE_PUBLISHABLE_KEY\""

PLATFORM="${1:-}"
PROFILE="${2:-}"

if [ "$PLATFORM" == "web" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d web-server --web-hostname localhost --web-port 3000"
elif [ "$PLATFORM" == "linux" ]; then
  if [ -n "${EKO_DATA_HOME:-}" ]; then
    export XDG_DATA_HOME="$EKO_DATA_HOME"
  elif [ -n "$PROFILE" ]; then
    export XDG_DATA_HOME="$HOME/.local/share/eko-$PROFILE"
  fi
  SQLITE_LIB_DIR=$(dirname "$(find /nix/store -maxdepth 3 -name "libsqlite3.so" 2>/dev/null | head -1)" 2>/dev/null || true)
  if [ -n "$SQLITE_LIB_DIR" ] && [ "$SQLITE_LIB_DIR" != "." ]; then
    export LD_LIBRARY_PATH="$SQLITE_LIB_DIR:$LD_LIBRARY_PATH"
  fi
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d linux"
elif [ -n "$PLATFORM" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d $PLATFORM"
fi

eval "$FLUTTER_COMMAND"
