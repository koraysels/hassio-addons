#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH=/data/options.json

# Read HA options with sane defaults
BOOKS_DIR=$(jq --raw-output  '.books_dir  // "/share/calibre/books"'  "${CONFIG_PATH}")
INGEST_DIR=$(jq --raw-output '.ingest_dir // "/share/calibre/ingest"' "${CONFIG_PATH}")
CONFIG_DIR=$(jq --raw-output '.config_dir // "/share/calibre/config"' "${CONFIG_PATH}")
PUID=$(jq --raw-output       '.PUID       // 1000'                    "${CONFIG_PATH}")
PGID=$(jq --raw-output       '.PGID       // 1000'                    "${CONFIG_PATH}")
TZ=$(jq --raw-output         '.TZ         // "UTC"'                   "${CONFIG_PATH}")

# Export env vars that CWA reads at startup
export PUID PGID TZ
export TRUSTED_PROXY_COUNT=1   # required for HA Ingress reverse-proxy header handling

# bind_mount <src> <dst>
# CWA declares VOLUME for these paths, so Docker mounts anonymous volumes there before
# this script runs. We unmount those and bind-mount the user's configured directories
# instead. Requires SYS_ADMIN capability (set in config.yaml).
bind_mount() {
    local src="$1" dst="$2"
    mkdir -p "${src}" "${dst}"
    if mountpoint -q "${dst}" 2>/dev/null; then
        umount "${dst}"
    fi
    mount --bind "${src}" "${dst}"
}

# Migrate any existing /config content to config_dir on first run before unmounting
if mountpoint -q /config 2>/dev/null; then
    if [ -n "$(ls -A /config 2>/dev/null)" ] && [ -z "$(ls -A "${CONFIG_DIR}" 2>/dev/null)" ]; then
        mkdir -p "${CONFIG_DIR}"
        cp -rp /config/. "${CONFIG_DIR}/"
    fi
fi

bind_mount "${BOOKS_DIR}"  /calibre-library
bind_mount "${INGEST_DIR}" /cwa-book-ingest
bind_mount "${CONFIG_DIR}" /config

# Hand control to CWA's S6 supervisor unchanged
exec /init
