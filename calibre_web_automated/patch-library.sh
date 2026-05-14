#!/usr/bin/with-contenv bash
# Runs synchronously via /custom-cont-init.d/ — AFTER cwa-init creates app.db
# but BEFORE any CWA service starts, so the library path is correct from the start.
set -euo pipefail

db="/config/app.db"
books_dir=$(jq --raw-output '.books_dir // "/share/calibre/books"' /data/options.json 2>/dev/null \
    || echo "/share/calibre/books")

mkdir -p "${books_dir}"

if [ ! -f "${db}" ]; then
    echo "[CWA-HA] patch-library: app.db not found yet (background job will retry)"
    exit 0
fi

current=$(sqlite3 "${db}" "SELECT config_calibre_dir FROM settings LIMIT 1;" 2>/dev/null || true)
if [ "${current}" = "${books_dir}" ]; then
    echo "[CWA-HA] patch-library: library path already correct (${books_dir})"
    exit 0
fi

sqlite3 "${db}" "UPDATE settings SET config_calibre_dir='${books_dir}';" \
    && echo "[CWA-HA] patch-library: library path → ${books_dir}" \
    || echo "[CWA-HA] patch-library: WARNING could not patch app.db"
