#!/usr/bin/env bash

FLUTTER_COMMAND="flutter run \
  --dart-define=USE_LOCAL=1 \
  --dart-define=SUPABASE_URL=\"$SUPABASE_URL\" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=\"$SUPABASE_PUBLISHABLE_KEY\""

if [ "$1" == "web" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d web-server --web-hostname localhost --web-port 3000"
elif [ "$1" == "linux" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d linux"
elif [ -n "$1" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d $1"
fi

eval "$FLUTTER_COMMAND"
