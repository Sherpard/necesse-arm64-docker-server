#!/bin/bash
set -e

BASE_DIR=/home/steam
SERVER_DIR="$BASE_DIR/server"
DATA_DIR="$BASE_DIR/data"
CACHE_DIR="$BASE_DIR/cache"
SAVES_DIR="$DATA_DIR/saves"

mkdir -p "$SERVER_DIR" "$DATA_DIR" "$CACHE_DIR"

# Ensure correct ownership
chown -R steam:steam "$BASE_DIR" || true

# --- Auto-update section ---
if [ "$AUTO_UPDATE" = "true" ]; then
  echo "🔄 Auto-update enabled..."
  /usr/local/bin/fetch-latest-server.sh "$BASE_DIR"
fi

# --- Saves linking (persistent volume) ---
# Ensure saves folder is mounted externally and linked into the server dir
if [ ! -L "$SERVER_DIR/saves" ]; then
  mkdir -p "$SAVES_DIR"
  rm -rf "$SERVER_DIR/saves" 2>/dev/null || true
  ln -sf "$SAVES_DIR" "$SERVER_DIR/saves"
fi

cd "$SERVER_DIR"

# --- Default configuration values ---
JAVA_MEMORY="${JAVA_MEMORY:-1G}"
SERVER_PORT="${SERVER_PORT:-14159}"
LOG_MODE="${LOG_MODE:-docker}"   # docker or files
LOGGING=1

# --- Logging setup ---
if [ "$LOG_MODE" = "docker" ]; then
  LOGS_PATH="/dev/null"  # discard log files, keep stdout
else
  LOGS_PATH="$DATA_DIR/logs"
  mkdir -p "$LOGS_PATH"
fi

# --- Build Java command ---
CMD=(java -Xmx${JAVA_MEMORY} -jar Server.jar -nogui)

# Conditional arguments based on environment
[[ -n "$SETTINGS_FILE" ]]       && CMD+=(-settings "$SETTINGS_FILE")
[[ -n "$WORLD_NAME" ]]          && CMD+=(-world "$WORLD_NAME")
[[ -n "$SLOTS" ]]               && CMD+=(-slots "$SLOTS")
[[ -n "$OWNER" ]]               && CMD+=(-owner "$OWNER")
[[ -n "$MOTD" ]]                && CMD+=(-motd "$MOTD")
[[ -n "$PASSWORD" ]]            && CMD+=(-password "$PASSWORD")
[[ -n "$PAUSE_WHEN_EMPTY" ]]    && CMD+=(-pausewhenempty "$PAUSE_WHEN_EMPTY")
[[ -n "$GIVE_CLIENTS_POWER" ]]  && CMD+=(-giveclientspower "$GIVE_CLIENTS_POWER")
[[ -n "$ZIP_SAVES" ]]           && CMD+=(-zipsaves "$ZIP_SAVES")
[[ -n "$LANGUAGE" ]]            && CMD+=(-language "$LANGUAGE")

# Always specify logging options
CMD+=(-logging "$LOGGING" -logs "$LOGS_PATH")

# Datadir or localdir setting
if [ "$LOCAL_DIR" = "1" ]; then
  CMD+=(-localdir)
else
  CMD+=(-datadir "$DATA_DIR")
fi

# --- Print environment summary ---
echo "🚀 Starting Necesse server..."
echo "----------------------------------------"
echo "Java Memory: ${JAVA_MEMORY}"
echo "World: ${WORLD_NAME:-<default>}"
echo "Port: ${SERVER_PORT}"
echo "Owner: ${OWNER:-<none>}"
echo "Log Mode: ${LOG_MODE} (${LOGS_PATH})"
echo "Data Dir: ${DATA_DIR}"
echo "----------------------------------------"


hide_next=0
for arg in "${CMD[@]}"; do
  if [ $hide_next -eq 1 ]; then
    printf '*** '
    hide_next=0
  elif [[ "$arg" == "-password" ]]; then
    printf '%s ' "$arg"
    hide_next=1
  else
    printf '%q ' "$arg"
  fi
done
echo
echo "----------------------------------------"

# --- Start the server ---
exec "${CMD[@]}"
