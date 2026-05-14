#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH=/data/options.json

BOOKS_DIR=$(jq --raw-output  '.books_dir  // "/share/calibre/books"'  "${CONFIG_PATH}")
INGEST_DIR=$(jq --raw-output '.ingest_dir // "/share/calibre/ingest"' "${CONFIG_PATH}")
PUID=$(jq --raw-output       '.PUID       // 1000'                    "${CONFIG_PATH}")
PGID=$(jq --raw-output       '.PGID       // 1000'                    "${CONFIG_PATH}")
TZ=$(jq --raw-output         '.TZ         // "UTC"'                   "${CONFIG_PATH}")

export PUID PGID TZ
export TRUSTED_PROXY_COUNT=1   # required for HA Ingress reverse-proxy header handling

# Create the user's share directories on first run
mkdir -p "${BOOKS_DIR}" "${INGEST_DIR}"

echo "[CWA-HA] Books dir : ${BOOKS_DIR}"
echo "[CWA-HA] Ingest dir: ${INGEST_DIR}"
echo "[CWA-HA] Config dir: /config (managed by HA addon_config)"

# CWA watches /cwa-book-ingest for new ebooks. That path is a Docker volume and
# cannot be redirected without elevated privileges. Instead, run a background loop
# that moves files from the user's configured ingest dir into CWA's watched path.
ingest_bridge() {
    while true; do
        find "${INGEST_DIR}" -maxdepth 1 -type f \
            -exec mv -n {} /cwa-book-ingest/ \; 2>/dev/null || true
        sleep 3
    done
}
ingest_bridge &

exec /init
