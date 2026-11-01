#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

FLUTTER_COMMAND="flutter run \
  --dart-define=USE_LOCAL=1 \
  --dart-define=SUPABASE_URL=\"$SUPABASE_URL\" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=\"$SUPABASE_PUBLISHABLE_KEY\" \
  ${MESSENGER_URL:+--dart-define=MESSENGER_URL=\"$MESSENGER_URL\"}"

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
  # plugins dlopen their libraries (e.g. libwebcrypto.so) by bare name, which
  # does not search the executable's $ORIGIN/lib
  export LD_LIBRARY_PATH="$PWD/build/linux/x64/debug/bundle/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  # use the dev shell's mesa so EGL loads against the app's glibc
  if [ -n "${EKO_GL_MESA:-}" ]; then
    export LD_LIBRARY_PATH="$EKO_GL_LIBGLVND/lib:$EKO_GL_MESA/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export __EGL_VENDOR_LIBRARY_FILENAMES="$EKO_GL_MESA/share/glvnd/egl_vendor.d/50_mesa.json"
    export LIBGL_DRIVERS_PATH="$EKO_GL_MESA/lib/dri"
    export GBM_BACKENDS_PATH="$EKO_GL_MESA/lib/gbm"
  fi
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d linux"
elif [ -n "$PLATFORM" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d $PLATFORM"
fi

eval "$FLUTTER_COMMAND"
