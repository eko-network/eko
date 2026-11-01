#!/usr/bin/env bash
# Local messenger development. Everything here is local and disposable:
# local Supabase, the eko-messenger server and its Postgres, app data in .dev/.
#
#   scripts/dev.sh up            start Supabase and Postgres, (re)start the messenger server
#   scripts/dev.sh down          stop the messenger server and its Postgres
#   scripts/dev.sh reset         wipe local Supabase (migrations + seed), the inbox and app data
#   scripts/dev.sh app [N]       build the Linux app, open N signed-out windows (default 2)
#   scripts/dev.sh app alice alice bob
#                                one signed-in window per account, each its own device
#   scripts/dev.sh e2e           headless multi-device test (needs `up`)
#   scripts/dev.sh logs          follow the server and Postgres logs
#
# Seeded accounts (password "password"): alice@test.local, bob@test.local, carol@test.local
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MESSENGER_DIR="${MESSENGER_DIR:-$ROOT/../eko-messenger}"
MESSENGER_URL="http://127.0.0.1:3000" # the server's dev shell sets PORT/DOMAIN to this
STATE="$ROOT/.dev"
LOGS="$STATE/logs"
mkdir -p "$LOGS"

log() { printf '\033[1m==>\033[0m %s\n' "$*"; }
die() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

port_open() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }

# Runs a command in the eko-messenger dev shell, which provides the local
# DATABASE_URL, SUPABASE_DB_URL, JWT_JWKS_URL and PORT.
in_messenger_shell() { (cd "$MESSENGER_DIR" && nix develop --impure -c "$@"); }

# Starts a background process in its own process group (setsid execs in
# place, so $! is the group leader) and logs to .dev/logs/<name>.log.
start_bg() {
  local name=$1
  shift
  (cd "$MESSENGER_DIR" && exec setsid nix develop --impure -c "$@") \
    >"$LOGS/$name.log" 2>&1 </dev/null &
  echo $! >"$STATE/$name.pid"
}

stop_bg() {
  local pid
  pid="$(cat "$STATE/$1.pid" 2>/dev/null)" || return 0
  kill -TERM -- "-$pid" 2>/dev/null || true
  rm -f "$STATE/$1.pid"
}

# Waits for a port while the named background process is alive.
wait_for() {
  local port=$1 name=$2
  until port_open "$port"; do
    kill -0 "$(cat "$STATE/$name.pid")" 2>/dev/null || {
      tail -n 30 "$LOGS/$name.log" >&2
      die "$name exited (log: $LOGS/$name.log)"
    }
    sleep 1
  done
}

supabase_env() {
  # exports API_URL, ANON_KEY, PUBLISHABLE_KEY, SERVICE_ROLE_KEY, ...
  local out
  out="$(supabase status -o env --workdir "$ROOT" 2>/dev/null)" || die "Supabase is not running (scripts/dev.sh up)"
  set -a
  eval "$out"
  set +a
}

stop_server() {
  stop_bg messenger
  pkill -f "target/debug/eko$" || true
  while port_open 3000; do sleep 0.5; done
}

cmd_up() {
  supabase status --workdir "$ROOT" >/dev/null 2>&1 || supabase start --workdir "$ROOT"

  if ! port_open 5432; then
    log "starting messenger Postgres"
    start_bg messenger-db devenv up --tui=false
    wait_for 5432 messenger-db
  fi

  stop_server
  # sqlx's query! macros check against the database at compile time
  log "migrating the messenger database"
  in_messenger_shell sqlx migrate run --source eko/migrations >"$LOGS/messenger-migrate.log" 2>&1 ||
    { tail -n 20 "$LOGS/messenger-migrate.log" >&2; die "messenger migrations failed"; }
  log "building and starting eko-messenger (first build takes a while)"
  start_bg messenger cargo run -p eko
  wait_for 3000 messenger

  log "ready: messenger $MESSENGER_URL, logs: scripts/dev.sh logs"
}

cmd_down() {
  stop_server
  stop_bg messenger-db
}

cmd_reset() {
  supabase db reset --workdir "$ROOT"
  # the inbox refers to devices that no longer exist
  port_open 5432 && in_messenger_shell bash -c 'psql "$DATABASE_URL" -qc "TRUNCATE entries, messages, group_epochs CASCADE"' >/dev/null
  rm -rf "$STATE/devices"
}

# True when a running app window uses $1 as its data dir.
data_dir_in_use() {
  local pid
  for pid in $(pgrep -f "bundle/eko$" || true); do
    tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | grep -qxF "XDG_DATA_HOME=$1" && return 0
  done
  return 1
}

cmd_app() {
  # a number opens that many signed-out windows, names open signed-in ones
  local windows=()
  if [[ $# -eq 0 ]]; then
    windows=(- -)
  elif [[ $# -eq 1 && "$1" =~ ^[0-9]+$ ]]; then
    for ((i = 0; i < $1; i++)); do windows+=(-); done
  else
    windows=("$@")
  fi
  supabase_env
  log "building the Linux app against local services"
  (cd "$ROOT/eko_app" && flutter build linux --debug \
    --dart-define=USE_LOCAL=1 \
    --dart-define=SUPABASE_URL="$API_URL" \
    --dart-define=SUPABASE_PUBLISHABLE_KEY="$PUBLISHABLE_KEY" \
    --dart-define=MESSENGER_URL="$MESSENGER_URL")
  local bin="$ROOT/eko_app/build/linux/x64/debug/bundle/eko"

  # The app links the flake's glibc, the host's mesa may need a newer one, so
  # EGL is pointed at a mesa from the same nixpkgs (the dev shell exports it).
  local mesa="${EKO_GL_MESA:-}" glvnd="${EKO_GL_LIBGLVND:-}"
  if [[ -z "$mesa" ]]; then
    mesa="$(nix build --inputs-from "$ROOT" nixpkgs#mesa --no-link --print-out-paths)"
    glvnd="$(nix build --inputs-from "$ROOT" nixpkgs#libglvnd --no-link --print-out-paths)"
  fi
  # plugins dlopen their libraries (e.g. libwebcrypto.so) by bare name, which
  # does not search the executable's $ORIGIN/lib
  export LD_LIBRARY_PATH="$(dirname "$bin")/lib:$glvnd/lib:$mesa/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  export __EGL_VENDOR_LIBRARY_FILENAMES="$mesa/share/glvnd/egl_vendor.d/50_mesa.json"
  export LIBGL_DRIVERS_PATH="$mesa/lib/dri"
  export GBM_BACKENDS_PATH="$mesa/lib/gbm"

  # "alice" -> alice@test.local. Each window takes the lowest alice-N data dir
  # no running window holds, so separate `app alice` calls get separate
  # devices and closed windows' devices are reused on the next launch.
  local who prefix email data name n
  for who in "${windows[@]}"; do
    if [[ "$who" == "-" ]]; then
      prefix="device"
      email=""
    else
      email="$who"
      [[ "$email" == *@* ]] || email="$who@test.local"
      prefix="${email%%@*}"
    fi
    for ((n = 1; ; n++)); do
      name="$prefix-$n"
      data="$STATE/devices/$name"
      data_dir_in_use "$data" || break
    done
    # each window gets its own data dir: prefs (device id), session, ecp.db, mls.db
    mkdir -p "$data"
    XDG_DATA_HOME="$data" EKO_DEV_EMAIL="$email" EKO_DEV_PASSWORD="${email:+password}" \
      setsid "$bin" >"$LOGS/app-$name.log" 2>&1 &
    log "$name started${email:+ as $email} (log: $LOGS/app-$name.log)"
  done
}

cmd_e2e() {
  supabase_env
  port_open 3000 || die "messenger server is not running (scripts/dev.sh up)"
  cd "$ROOT/scripts/messenger_e2e"
  dart pub get >/dev/null
  SUPABASE_URL="$API_URL" \
    SUPABASE_ANON_KEY="$ANON_KEY" \
    SUPABASE_SERVICE_ROLE_KEY="$SERVICE_ROLE_KEY" \
    MESSENGER_URL="$MESSENGER_URL" \
    dart run bin/messenger_e2e.dart
}

case "${1:-}" in
  up) cmd_up ;;
  down) cmd_down ;;
  reset) cmd_reset ;;
  app) shift; cmd_app "$@" ;;
  e2e) cmd_e2e ;;
  logs) tail -n 50 -F "$LOGS"/messenger*.log ;;
  *) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
