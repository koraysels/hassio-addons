#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH=/data/options.json

BOOKS_DIR=$(jq --raw-output  '.books_dir  // "/share/calibre/books"'  "${CONFIG_PATH}")
INGEST_DIR=$(jq --raw-output '.ingest_dir // "/share/calibre/ingest"' "${CONFIG_PATH}")
PUID=$(jq --raw-output       '.PUID       // 1000'                    "${CONFIG_PATH}")
PGID=$(jq --raw-output       '.PGID       // 1000'                    "${CONFIG_PATH}")
TZ=$(jq --raw-output         '.TZ         // "UTC"'                   "${CONFIG_PATH}")

export PUID PGID TZ
export TRUSTED_PROXY_COUNT=2  # HA Ingress → nginx → CWA: two proxy hops

mkdir -p "${BOOKS_DIR}" "${INGEST_DIR}"

echo "[CWA-HA] Books dir : ${BOOKS_DIR}"
echo "[CWA-HA] Ingest dir: ${INGEST_DIR}"

# --- Library redirect ---
# The upstream CWA image declared /calibre-library as a Docker VOLUME. Our
# multi-stage Dockerfile (FROM scratch) strips that declaration, making it a
# plain directory. We replace it with a symlink so every write CWA makes to
# /calibre-library lands directly in books_dir — no rsync, no duplication.
rm -rf /calibre-library
ln -sf "${BOOKS_DIR}" /calibre-library
echo "[CWA-HA] Symlinked /calibre-library → ${BOOKS_DIR}"

# Fix ownership so CWA (running as abc/PUID) can rename and delete any files,
# including those created by root in earlier runs before the symlink was in place.
chown -R "${PUID}:${PGID}" "${BOOKS_DIR}" 2>/dev/null || true

# --- HA Ingress nginx proxy ---
# HA connects to ingress_port (8099). nginx proxies to CWA at 8083 and injects
# X-Script-Name so Calibre-Web (Flask) generates correct URLs inside the HA iframe.
# Without X-Script-Name, static assets and redirects use root-relative URLs that
# resolve to ha.local:8123/static/... instead of ha.local:8123/<token>/static/...
INGRESS_ENTRY=""
if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
    INGRESS_ENTRY=$(curl -sf \
        -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
        http://supervisor/addons/self/info \
        | jq -r '.data.ingress_entry // ""' 2>/dev/null || true)
fi
echo "[CWA-HA] Ingress entry: ${INGRESS_ENTRY:-/}"

cat > /tmp/cwa-ingress.nginx.conf << NGINX_EOF
daemon off;
pid /tmp/cwa-ingress.nginx.pid;
worker_processes 1;
error_log /proc/1/fd/1 error;

events { worker_connections 512; }

http {
    default_type application/octet-stream;
    client_max_body_size 0;

    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        ''      close;
    }

    server {
        listen 8099 default_server;

        location / {
            proxy_pass          http://127.0.0.1:8083;
            proxy_set_header    X-Script-Name       ${INGRESS_ENTRY};
            proxy_set_header    Host                \$http_host;
            proxy_set_header    X-Real-IP           \$remote_addr;
            proxy_set_header    X-Forwarded-For     \$proxy_add_x_forwarded_for;
            proxy_set_header    X-Forwarded-Proto   \$scheme;
            proxy_set_header    Upgrade             \$http_upgrade;
            proxy_set_header    Connection          \$connection_upgrade;
            proxy_buffering     off;
            proxy_read_timeout  36000s;
        }
    }
}
NGINX_EOF

nginx -c /tmp/cwa-ingress.nginx.conf &
echo "[CWA-HA] nginx ingress proxy started on port 8099"

# --- Upload size patch ---
# CWA's config_upload_size defaults to 16 MB and isn't exposed in the UI.
# We wait until CWA is fully started (port 8083), patch the DB, then restart
# the CWA web process so it re-reads the new value immediately.
patch_upload_limit() {
    local db="/config/app.db"
    local retries=0

    # Wait for CWA web server to be accepting connections
    while [ ${retries} -lt 90 ]; do
        (echo "" > /dev/tcp/127.0.0.1/8083) 2>/dev/null && break
        sleep 2; retries=$((retries + 1))
    done
    sleep 2

    if [ ! -f "${db}" ]; then
        echo "[CWA-HA] WARNING: app.db not found, skipping upload size patch"
        return
    fi

    # Check if already patched (survives restarts once set)
    local current
    current=$(sqlite3 "${db}" "SELECT config_upload_size FROM settings LIMIT 1;" 2>/dev/null || echo "0")
    if [ "${current}" = "2048" ]; then
        echo "[CWA-HA] Upload size already 2048 MB"
        return
    fi

    if sqlite3 "${db}" "UPDATE settings SET config_upload_size=2048;" 2>/dev/null; then
        echo "[CWA-HA] Upload size patched to 2048 MB — restarting CWA web server..."
        # Kill the process listening on 8083; S6 restarts it with the new DB value
        local web_pid
        web_pid=$(ss -Htlnp 'sport = :8083' 2>/dev/null | grep -oP 'pid=\K\d+' | head -1 || true)
        if [ -n "${web_pid}" ]; then
            kill -TERM "${web_pid}" 2>/dev/null || true
            echo "[CWA-HA] CWA web server restarting (was pid ${web_pid})"
        else
            echo "[CWA-HA] WARNING: could not find CWA web pid to restart — restart the addon manually"
        fi
    else
        local schema_cols
        schema_cols=$(sqlite3 "${db}" "PRAGMA table_info(settings);" 2>/dev/null \
            | awk -F'|' '{print $2}' | tr '\n' ',' || echo "error reading schema")
        echo "[CWA-HA] WARNING: could not patch upload size (settings columns: ${schema_cols})"
    fi
}
patch_upload_limit &

# --- Ingest bridge ---
# CWA watches /cwa-book-ingest. Bridge files from the user's share ingest dir into it.
ingest_bridge() {
    while true; do
        find "${INGEST_DIR}" -maxdepth 1 -type f \
            -exec mv -n {} /cwa-book-ingest/ \; 2>/dev/null || true
        sleep 3
    done
}
ingest_bridge &

exec /init
