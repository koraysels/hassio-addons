#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH=/data/options.json

BOOKS_DIR=$(jq --raw-output  '.books_dir  // "/share/calibre/books"'  "${CONFIG_PATH}")
INGEST_DIR=$(jq --raw-output '.ingest_dir // "/share/calibre/ingest"' "${CONFIG_PATH}")
PUID=$(jq --raw-output       '.PUID       // 1000'                    "${CONFIG_PATH}")
PGID=$(jq --raw-output       '.PGID       // 1000'                    "${CONFIG_PATH}")
TZ=$(jq --raw-output         '.TZ         // "UTC"'                   "${CONFIG_PATH}")

export PUID PGID TZ
export TRUSTED_PROXY_COUNT=1

mkdir -p "${BOOKS_DIR}" "${INGEST_DIR}"

echo "[CWA-HA] Books dir : ${BOOKS_DIR}"
echo "[CWA-HA] Ingest dir: ${INGEST_DIR}"
echo "[CWA-HA] Config dir: /config (managed by HA addon_config)"

# Point CWA's library at the user's share path.
# CWA stores this in /config/app.db (SQLite). We update it here so the user
# never has to touch CWA's admin UI — the HA configuration tab is the single
# source of truth. We wait for cwa-init to create app.db, then patch it.
set_library_path() {
    local db="/config/app.db"
    local retries=0
    while [ ! -f "${db}" ] && [ ${retries} -lt 30 ]; do
        sleep 1
        retries=$((retries + 1))
    done
    if [ ! -f "${db}" ]; then
        echo "[CWA-HA] WARNING: app.db not found after 30s, skipping library path patch"
        return
    fi
    # Only patch if the stored path differs from the configured one
    local current
    current=$(sqlite3 "${db}" \
        "SELECT config_calibre_dir FROM settings LIMIT 1;" 2>/dev/null || echo "")
    if [ "${current}" != "${BOOKS_DIR}" ]; then
        sqlite3 "${db}" \
            "UPDATE settings SET config_calibre_dir='${BOOKS_DIR}';" 2>/dev/null && \
            echo "[CWA-HA] Library path set to: ${BOOKS_DIR}" || \
            echo "[CWA-HA] WARNING: could not patch library path in app.db"
    else
        echo "[CWA-HA] Library path already correct: ${BOOKS_DIR}"
    fi
}
set_library_path &

# Bridge files from user's share ingest dir into CWA's watched /cwa-book-ingest.
ingest_bridge() {
    while true; do
        find "${INGEST_DIR}" -maxdepth 1 -type f \
            -exec mv -n {} /cwa-book-ingest/ \; 2>/dev/null || true
        sleep 3
    done
}
ingest_bridge &

exec /init
