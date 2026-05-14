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

# --- Library → Samba sync ---
# CWA always stores its library at /calibre-library (a Docker VOLUME declared in
# the upstream image). We cannot reliably redirect that volume via bind mount in
# all HA configurations, so we instead rsync /calibre-library → books_dir every
# 30 seconds. Books appear in the Samba share within half a minute of being added.
# If the bind mount IS available (full_access: true granted), it is attempted first
# so the sync becomes a free no-op.
if mount --bind "${BOOKS_DIR}" /calibre-library 2>/dev/null; then
    echo "[CWA-HA] Bound ${BOOKS_DIR} → /calibre-library (zero-lag Samba access)"
else
    echo "[CWA-HA] Bind mount unavailable; rsync will mirror to ${BOOKS_DIR} every 30s"
fi

sync_library() {
    while true; do
        sleep 30
        rsync -a --quiet /calibre-library/ "${BOOKS_DIR}/" 2>/dev/null || true
    done
}
sync_library &

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
# auto_library.py only resets config_calibre_dir, so this patch survives restarts.
patch_upload_limit() {
    local db="/config/app.db"
    local retries=0
    while [ ! -f "${db}" ] && [ ${retries} -lt 30 ]; do
        sleep 1; retries=$((retries + 1))
    done
    if [ -f "${db}" ]; then
        sqlite3 "${db}" "UPDATE settings SET config_upload_size=2048;" 2>/dev/null \
            && echo "[CWA-HA] Upload size limit set to 2048 MB" \
            || echo "[CWA-HA] WARNING: could not patch upload size"
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
