#!/bin/bash
set -e

BASE_DIR=${1:-/home/steam}
CACHE_DIR="$BASE_DIR/cache"
SERVER_DIR="$BASE_DIR/server"
CACHE_FILE="$SERVER_DIR/.last_download_url"

mkdir -p "$CACHE_DIR" "$SERVER_DIR"

echo "Fetching latest Necesse server version info..."

REL_URL=$(wget -qO- https://necessegame.com/server/ \
  | grep -Eo 'href="/content/server/[0-9-]+/necesse-server-linux64-[0-9-]+\.zip"' \
  | sed -E 's/href="([^"]+)"/\1/' \
  | head -n 1)

if [ -z "$REL_URL" ]; then
  echo "❌ Could not find latest Linux64 server ZIP on the website."
  exit 1
fi

URL="https://necessegame.com${REL_URL}"
FILENAME=$(basename "$URL")
VERSION=$(echo "$FILENAME" | sed -E 's/.*linux64-([0-9-]+)\.zip/\1/')
ZIP_PATH="$CACHE_DIR/$FILENAME"

if [ -f "$CACHE_FILE" ]; then
  LAST_URL=$(cat "$CACHE_FILE" 2>/dev/null || true)
  if [ "$URL" = "$LAST_URL" ]; then
    echo "ℹ️ Already up to date (version $VERSION)"
    exit 0
  fi
fi

if [ -f "$ZIP_PATH" ]; then
  echo "♻️ Using cached server archive: $ZIP_PATH"
else
  echo "📦 Downloading version $VERSION ..."
  wget -q -O "$ZIP_PATH" "$URL"
fi


# Cleanup old cache entries: keep only the newest 3 files
KEEP=3

echo "🗑️ Cleaning old cache entries (keeping $KEEP newest)..."

# Ensure we only keep the newest $KEEP files
mapfile -t _files < <(ls -1t "$CACHE_DIR"/necesse-server-linux64-*.zip 2>/dev/null || true)
if [ "${#_files[@]}" -gt "$KEEP" ]; then
  for f in "${_files[@]:$KEEP}"; do
    [ "$f" != "$ZIP_PATH" ] && rm -f -- "$f"
  done
fi


TMP_DIR=$(mktemp -d)
unzip -q "$ZIP_PATH" -d "$TMP_DIR"
INNER_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)

echo "🧹 Cleaning old server files..."
find "$SERVER_DIR" -mindepth 1 -maxdepth 1 \
  ! -name '.last_download_url' \
  -exec rm -rf {} +

if [ -d "$INNER_DIR" ]; then
  echo "📂 Flattening extracted folder structure..."
  shopt -s dotglob nullglob
  mv "$INNER_DIR"/* "$SERVER_DIR"/
  shopt -u dotglob nullglob
else
  mv "$TMP_DIR"/* "$SERVER_DIR"/
fi

rm -rf "$TMP_DIR"
echo "$URL" > "$CACHE_FILE"

echo "✅ Server updated to version $VERSION"
