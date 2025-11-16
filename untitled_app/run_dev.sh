#!/usr/bin/env bash

FLUTTER_COMMAND="flutter run \
--dart-define=\"TENOR_API_KEY=$TENOR_API_KEY\" \
--dart-define=\"SEARCH_API_KEY=$SEARCH_API_KEY\" \
--dart-define=\"ALGOLIA_APP_ID=$ALGOLIA_APP_ID\""

if [ "$1" == "web" ]; then
  FLUTTER_COMMAND="$FLUTTER_COMMAND -d web-server --web-hostname localhost --web-port 3000"
fi

eval $FLUTTER_COMMAND
